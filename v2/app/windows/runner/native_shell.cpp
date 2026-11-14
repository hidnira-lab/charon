#include "native_shell.h"

#include <dwmapi.h>
#include <flutter/standard_method_codec.h>
#include <shellapi.h>

#include <flutter_windows.h>

#include <algorithm>
#include <cmath>
#include <cstring>

namespace {

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

constexpr UINT kTrayId = 1;
constexpr int kMaxTooltip = 127;  // NOTIFYICONDATA keeps 128 wide characters.
constexpr int kFlyoutGap = 12;    // logical pixels between the flyout and the taskbar
constexpr ULONGLONG kToggleGuardMs = 350;

// The outline of a box with stepped corners, as the NotchBox of the app draws it.
HRGN NotchRegion(int w, int h, int a) {
  const int b = a / 2;
  POINT pts[20] = {
      {a, 0},     {w - a, 0},     {w - a, b},     {w - b, b},     {w - b, a},
      {w, a},     {w, h - a},     {w - b, h - a}, {w - b, h - b}, {w - a, h - b},
      {w - a, h}, {a, h},         {a, h - b},     {b, h - b},     {b, h - a},
      {0, h - a}, {0, a},         {b, a},         {b, b},         {a, b},
  };
  return CreatePolygonRgn(pts, 20, WINDING);
}

void SetCorners(HWND window, DWORD preference) {
  DwmSetWindowAttribute(window, 33 /* DWMWA_WINDOW_CORNER_PREFERENCE */,
                        &preference, sizeof(preference));
}

const EncodableValue* Find(const EncodableMap& map, const char* key) {
  auto it = map.find(EncodableValue(std::string(key)));
  return it == map.end() ? nullptr : &it->second;
}

std::string Text(const EncodableMap& map, const char* key) {
  if (const auto* v = Find(map, key)) {
    if (const auto* s = std::get_if<std::string>(v)) return *s;
  }
  return {};
}

bool Flag(const EncodableMap& map, const char* key) {
  if (const auto* v = Find(map, key)) {
    if (const auto* b = std::get_if<bool>(v)) return *b;
  }
  return false;
}

int Number(const EncodableMap& map, const char* key) {
  if (const auto* v = Find(map, key)) return static_cast<int>(v->LongValue());
  return 0;
}

std::wstring Wide(const std::string& utf8) {
  if (utf8.empty()) return {};
  int n = MultiByteToWideChar(CP_UTF8, 0, utf8.data(),
                              static_cast<int>(utf8.size()), nullptr, 0);
  std::wstring out(n, L'\0');
  MultiByteToWideChar(CP_UTF8, 0, utf8.data(), static_cast<int>(utf8.size()),
                      out.data(), n);
  return out;
}

}  // namespace

NativeShell::NativeShell(HWND window, flutter::BinaryMessenger* messenger)
    : window_(window),
      taskbar_created_(RegisterWindowMessageW(L"TaskbarCreated")) {
  channel_ = std::make_unique<flutter::MethodChannel<Value>>(
      messenger, "charon/window", &flutter::StandardMethodCodec::GetInstance());
  channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<Value>& call,
             std::unique_ptr<flutter::MethodResult<Value>> result) {
        OnCall(call, std::move(result));
      });

  // A window without a frame keeps its rounded corners and its shadow.
  SetCorners(window_, 2 /* DWMWCP_ROUND */);
  const MARGINS margins = {0, 0, 1, 0};
  DwmExtendFrameIntoClientArea(window_, &margins);
  // The frame was first calculated while the window was being made, before it
  // answered WM_NCCALCSIZE. Calculate it again, so the client area is the whole
  // window from the first frame on.
  SetWindowPos(window_, nullptr, 0, 0, 0, 0,
               SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE |
                   SWP_FRAMECHANGED);
}

NativeShell::~NativeShell() {
  RemoveTray();
  channel_ = nullptr;
}

void NativeShell::OnCall(
    const flutter::MethodCall<Value>& call,
    std::unique_ptr<flutter::MethodResult<Value>> result) {
  const std::string& name = call.method_name();
  if (name == "ready") {
    ready_ = true;
  } else if (name == "hide") {
    LeaveFlyout();
    ShowWindow(window_, SW_HIDE);
  } else if (name == "show") {
    LeaveFlyout();
    ShowWindowAndFocus();
  } else if (name == "showFlyout") {
    if (const auto* args = std::get_if<EncodableMap>(call.arguments())) {
      ShowFlyout(Number(*args, "width"), Number(*args, "height"),
                 Number(*args, "notch"));
    }
  } else if (name == "hideFlyout") {
    LeaveFlyout();
  } else if (name == "quit") {
    RemoveTray();
    DestroyWindow(window_);
  } else if (name == "startDrag") {
    // The title bar is drawn by Flutter: hand the mouse to Windows as if the
    // caption had been pressed, and it runs the move.
    ReleaseCapture();
    SendMessage(window_, WM_NCLBUTTONDOWN, HTCAPTION, 0);
  } else if (name == "setTray") {
    if (const auto* args = std::get_if<EncodableMap>(call.arguments())) {
      SetTray(*args);
    }
  } else if (name == "removeTray") {
    RemoveTray();
  } else {
    result->NotImplemented();
    return;
  }
  result->Success();
}

void NativeShell::ShowWindowAndFocus() {
  ShowWindow(window_, IsIconic(window_) ? SW_RESTORE : SW_SHOW);
  BringWindowToTop(window_);
  SetForegroundWindow(window_);
}

// Where the tray icon is, so the flyout can open above it. Windows tells when
// the icon is on the taskbar; when it is in the overflow, the click is the best
// answer there is.
POINT NativeShell::TrayAnchor() {
  NOTIFYICONIDENTIFIER id = {};
  id.cbSize = sizeof(id);
  id.hWnd = window_;
  id.uID = kTrayId;
  RECT r = {};
  if (SUCCEEDED(Shell_NotifyIconGetRect(&id, &r)) && r.right > r.left) {
    return {(r.left + r.right) / 2, (r.top + r.bottom) / 2};
  }
  return click_;
}

void NativeShell::ShowFlyout(int width, int height, int notch) {
  if (width <= 0 || height <= 0) return;
  flyout_width_ = width;
  flyout_height_ = height;
  flyout_notch_ = notch > 0 ? notch : 12;

  if (!flyout_) {
    // Remember the main window, then change what kind of window this is. The
    // style of the taskbar button only changes while the window is hidden.
    WINDOWPLACEMENT placement = {};
    placement.length = sizeof(placement);
    GetWindowPlacement(window_, &placement);
    main_rect_ = placement.rcNormalPosition;
    ShowWindow(window_, SW_HIDE);
    const LONG_PTR ex = GetWindowLongPtr(window_, GWL_EXSTYLE);
    SetWindowLongPtr(window_, GWL_EXSTYLE,
                     (ex | WS_EX_TOOLWINDOW) & ~static_cast<LONG_PTR>(WS_EX_APPWINDOW));
    SetCorners(window_, 1 /* DWMWCP_DONOTROUND: the corners are the notch */);
    anchor_ = TrayAnchor();
    flyout_ = true;
  }
  PlaceFlyout();
  if (!IsWindowVisible(window_)) ShowWindow(window_, SW_SHOWNOACTIVATE);
  // It must have the focus, or it could not tell when you click elsewhere.
  SetForegroundWindow(window_);
}

// The flyout sits 12 px from the taskbar, on the side the taskbar is on, over
// the icon, and inside the work area of that monitor, at that monitor's scale.
void NativeShell::PlaceFlyout() {
  HMONITOR monitor = MonitorFromPoint(anchor_, MONITOR_DEFAULTTONEAREST);
  MONITORINFO info = {};
  info.cbSize = sizeof(info);
  GetMonitorInfo(monitor, &info);
  const double scale = FlutterDesktopGetDpiForMonitor(monitor) / 96.0;
  const int w = static_cast<int>(std::lround(flyout_width_ * scale));
  const int h = static_cast<int>(std::lround(flyout_height_ * scale));
  const int gap = static_cast<int>(std::lround(kFlyoutGap * scale));
  const RECT work = info.rcWork, full = info.rcMonitor;

  int x, y;
  if (work.top > full.top) {  // taskbar on top
    x = anchor_.x - w / 2;
    y = work.top + gap;
  } else if (work.left > full.left) {  // on the left
    x = work.left + gap;
    y = anchor_.y - h / 2;
  } else if (work.right < full.right) {  // on the right
    x = work.right - w - gap;
    y = anchor_.y - h / 2;
  } else {  // at the bottom, or hidden away: the bottom is where trays are
    x = anchor_.x - w / 2;
    y = work.bottom - h - gap;
  }
  x = std::max<int>(work.left, std::min<int>(x, work.right - w));
  y = std::max<int>(work.top, std::min<int>(y, work.bottom - h));

  SetWindowPos(window_, HWND_TOPMOST, x, y, w, h, SWP_NOACTIVATE);
  SetWindowRgn(window_, NotchRegion(w, h, static_cast<int>(std::lround(flyout_notch_ * scale))), TRUE);
}

void NativeShell::LeaveFlyout() {
  if (!flyout_) return;
  flyout_ = false;
  ShowWindow(window_, SW_HIDE);
  SetWindowRgn(window_, nullptr, TRUE);
  const LONG_PTR ex = GetWindowLongPtr(window_, GWL_EXSTYLE);
  SetWindowLongPtr(window_, GWL_EXSTYLE, ex & ~static_cast<LONG_PTR>(WS_EX_TOOLWINDOW));
  SetCorners(window_, 2 /* DWMWCP_ROUND */);
  // Twice: moving back to a monitor with another scale makes Windows resize the
  // window once on its own, and the second call puts it where it was.
  for (int i = 0; i < 2; ++i) {
    SetWindowPos(window_, HWND_NOTOPMOST, main_rect_.left, main_rect_.top,
                 main_rect_.right - main_rect_.left,
                 main_rect_.bottom - main_rect_.top, SWP_NOACTIVATE);
  }
}

void NativeShell::DismissFlyout() {
  if (!flyout_) return;
  LeaveFlyout();
  dismissed_at_ = GetTickCount64();
  Event("flyoutDismissed");
}

void NativeShell::AfterDpiChanged() {
  if (flyout_) PlaceFlyout();
}

void NativeShell::SetTray(const EncodableMap& args) {
  std::wstring tip = Wide(Text(args, "tooltip"));
  if (static_cast<int>(tip.size()) > kMaxTooltip) tip.resize(kMaxTooltip);
  tooltip_ = tip;

  icons_.clear();
  if (const auto* v = Find(args, "icons")) {
    if (const auto* map = std::get_if<EncodableMap>(v)) {
      for (const auto& [key, value] : *map) {
        if (const auto* pixels = std::get_if<std::vector<uint8_t>>(&value)) {
          icons_[static_cast<int>(key.LongValue())] = *pixels;
        }
      }
    }
  }
  if (const auto* v = Find(args, "menu")) {
    if (const auto* list = std::get_if<EncodableList>(v)) menu_ = *list;
  }
  ApplyTray();
}

// The icon that fits the size Windows wants for the tray at this scaling, from
// the ones Dart drew: the smallest that is big enough, else the biggest.
HICON NativeShell::MakeIcon() {
  if (icons_.empty()) return nullptr;
  const int want = GetSystemMetricsForDpi(SM_CXSMICON, GetDpiForWindow(window_));
  const std::vector<uint8_t>* pixels = nullptr;
  int size = 0;
  for (const auto& [edge, data] : icons_) {
    pixels = &data;
    size = edge;
    if (edge >= want) break;
  }
  if (!pixels || size <= 0 ||
      pixels->size() != static_cast<size_t>(size) * size * 4) {
    return nullptr;
  }

  BITMAPV5HEADER header = {};
  header.bV5Size = sizeof(header);
  header.bV5Width = size;
  header.bV5Height = -size;  // top down
  header.bV5Planes = 1;
  header.bV5BitCount = 32;
  header.bV5Compression = BI_BITFIELDS;
  header.bV5RedMask = 0x00FF0000;
  header.bV5GreenMask = 0x0000FF00;
  header.bV5BlueMask = 0x000000FF;
  header.bV5AlphaMask = 0xFF000000;

  HDC dc = GetDC(nullptr);
  void* bits = nullptr;
  HBITMAP color = CreateDIBSection(dc, reinterpret_cast<BITMAPINFO*>(&header),
                                   DIB_RGB_COLORS, &bits, nullptr, 0);
  ReleaseDC(nullptr, dc);
  if (!color || !bits) return nullptr;
  std::memcpy(bits, pixels->data(), pixels->size());

  HBITMAP mask = CreateBitmap(size, size, 1, 1, nullptr);
  ICONINFO info = {};
  info.fIcon = TRUE;
  info.hbmMask = mask;
  info.hbmColor = color;
  HICON icon = CreateIconIndirect(&info);
  DeleteObject(color);
  DeleteObject(mask);
  return icon;
}

void NativeShell::ApplyTray() {
  HICON next = MakeIcon();
  if (!next) return;

  NOTIFYICONDATAW data = {};
  data.cbSize = sizeof(data);
  data.hWnd = window_;
  data.uID = kTrayId;
  data.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP;
  data.uCallbackMessage = kTrayMessage;
  data.hIcon = next;
  wcsncpy_s(data.szTip, tooltip_.c_str(), _TRUNCATE);

  if (Shell_NotifyIconW(tray_added_ ? NIM_MODIFY : NIM_ADD, &data)) {
    tray_added_ = true;
  } else if (tray_added_) {
    // Explorer lost the icon: add it again.
    tray_added_ = Shell_NotifyIconW(NIM_ADD, &data) != FALSE;
  }
  if (icon_) DestroyIcon(icon_);
  icon_ = next;
}

void NativeShell::RemoveTray() {
  if (tray_added_) {
    NOTIFYICONDATAW data = {};
    data.cbSize = sizeof(data);
    data.hWnd = window_;
    data.uID = kTrayId;
    Shell_NotifyIconW(NIM_DELETE, &data);
    tray_added_ = false;
  }
  if (icon_) {
    DestroyIcon(icon_);
    icon_ = nullptr;
  }
}

HMENU NativeShell::BuildMenu(const EncodableList& items) {
  HMENU menu = CreatePopupMenu();
  if (!menu) return nullptr;
  UINT bold_id = 0;
  for (const auto& item : items) {
    const auto* map = std::get_if<EncodableMap>(&item);
    if (!map) continue;
    if (Flag(*map, "separator")) {
      AppendMenuW(menu, MF_SEPARATOR, 0, nullptr);
      continue;
    }
    std::wstring label = Wide(Text(*map, "label"));
    const std::wstring note = Wide(Text(*map, "note"));
    // A tab sends the note to the quiet column at the right.
    if (!note.empty()) label += L"\t" + note;

    UINT flags = MF_STRING;
    if (!Flag(*map, "enabled")) flags |= MF_GRAYED;
    if (Flag(*map, "checked")) flags |= MF_CHECKED;

    const auto* kids = Find(*map, "children");
    const auto* list = kids ? std::get_if<EncodableList>(kids) : nullptr;
    if (list && !list->empty()) {
      HMENU sub = BuildMenu(*list);
      if (sub) {
        AppendMenuW(menu, flags | MF_POPUP, reinterpret_cast<UINT_PTR>(sub),
                    label.c_str());
      }
      continue;
    }
    const UINT id = static_cast<UINT>(Number(*map, "id"));
    AppendMenuW(menu, flags, id, label.c_str());
    if (Flag(*map, "bold") && bold_id == 0) bold_id = id;
  }
  if (bold_id != 0) SetMenuDefaultItem(menu, bold_id, FALSE);
  return menu;
}

void NativeShell::ShowMenu() {
  HMENU menu = BuildMenu(menu_);
  if (!menu) return;
  POINT at;
  GetCursorPos(&at);
  // The menu closes when you click elsewhere only if its window has the focus.
  SetForegroundWindow(window_);
  const UINT picked = static_cast<UINT>(TrackPopupMenu(
      menu, TPM_RETURNCMD | TPM_RIGHTBUTTON | TPM_BOTTOMALIGN | TPM_LEFTALIGN,
      at.x, at.y, 0, window_, nullptr));
  PostMessage(window_, WM_NULL, 0, 0);
  DestroyMenu(menu);
  if (picked != 0) Event("menuCommand", Value(static_cast<int>(picked)));
}

void NativeShell::Event(const std::string& name, Value argument) {
  if (!channel_) return;
  channel_->InvokeMethod(name, std::make_unique<Value>(std::move(argument)));
}

bool NativeShell::RequestClose() {
  if (!ready_) return false;
  Event("closeRequested");
  return true;
}

std::optional<LRESULT> NativeShell::HandleMessage(HWND, UINT message,
                                                  WPARAM wparam,
                                                  LPARAM lparam) {
  if (message == kTrayMessage && wparam == kTrayId) {
    switch (LOWORD(lparam)) {
      case WM_LBUTTONUP:
        // Pressing the icon took the focus from the flyout and closed it: the
        // release that follows must not open it again.
        if (GetTickCount64() - dismissed_at_ < kToggleGuardMs) break;
        GetCursorPos(&click_);
        Event("trayLeftClick",
              Value(IsWindowVisible(window_) && !IsIconic(window_)));
        break;
      case WM_LBUTTONDBLCLK:
        Event("trayDoubleClick");
        break;
      case WM_RBUTTONUP:
        GetCursorPos(&click_);
        ShowMenu();
        break;
    }
    return 0;
  }
  if (message == WM_ACTIVATE && flyout_ && LOWORD(wparam) == WA_INACTIVE) {
    DismissFlyout();
    return std::nullopt;  // the rest of the window still hears about it
  }
  if (message == taskbar_created_) {
    // Explorer restarted and took the icons with it.
    tray_added_ = false;
    ApplyTray();
    return 0;
  }
  return std::nullopt;
}
