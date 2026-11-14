#include "native_shell.h"

#include <dwmapi.h>
#include <flutter/standard_method_codec.h>
#include <shellapi.h>

#include <cmath>
#include <cstring>

namespace {

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

constexpr UINT kTrayId = 1;
constexpr int kMaxTooltip = 127;  // NOTIFYICONDATA keeps 128 wide characters.

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
  const DWORD round = 2;  // DWMWCP_ROUND
  DwmSetWindowAttribute(window_, 33 /* DWMWA_WINDOW_CORNER_PREFERENCE */,
                        &round, sizeof(round));
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
    ShowWindow(window_, SW_HIDE);
  } else if (name == "show") {
    ShowWindowAndFocus();
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
        Event("trayLeftClick");
        break;
      case WM_LBUTTONDBLCLK:
        Event("trayDoubleClick");
        break;
      case WM_RBUTTONUP:
        ShowMenu();
        break;
    }
    return 0;
  }
  if (message == taskbar_created_) {
    // Explorer restarted and took the icons with it.
    tray_added_ = false;
    ApplyTray();
    return 0;
  }
  return std::nullopt;
}
