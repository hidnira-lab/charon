#ifndef RUNNER_NATIVE_SHELL_H_
#define RUNNER_NATIVE_SHELL_H_

#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <windows.h>

#include <map>
#include <memory>
#include <optional>
#include <string>
#include <vector>

// The tray icon sends this to the window.
constexpr UINT kTrayMessage = WM_APP + 1;

// What only Windows can do for the Charon window, behind one method channel
// ("charon/window"): the frameless window (move, hide, show, quit),
// the tray icon with its tooltip and its native right click menu, and the
// events the Dart side acts on. Charon has no plugin for any of it, so this is
// all of it.
//
// The tray flyout is this same window, changed in shape: smaller, without a
// taskbar button, on top, with the stepped corners of the board, and above the
// tray icon. It goes back to the main window's place when it closes.
//
// Dart to native: ready, hide, show, quit, startDrag, setTray, removeTray,
// showFlyout (width, height, notch in logical pixels, and open: true for the
// call that opens it, false for the ones that only change its height), hideFlyout.
// Native to Dart: closeRequested, trayLeftClick (with whether the window is
// showing), trayDoubleClick, menuCommand (the id of the picked item),
// flyoutDismissed (the window lost the focus).
class NativeShell {
 public:
  NativeShell(HWND window, flutter::BinaryMessenger* messenger);
  ~NativeShell();

  // Handles the messages this class owns. Returns the result when it did.
  std::optional<LRESULT> HandleMessage(HWND hwnd, UINT message, WPARAM wparam,
                                       LPARAM lparam);

  // The user or the system asked the window to close. When Dart is listening
  // the answer is its to give and this returns true; otherwise the window
  // closes as usual.
  bool RequestClose();

  // The window is on the flyout's size and place (Win32Window asks this after
  // a change of DPI, which would otherwise resize it as the main window).
  void AfterDpiChanged();

 private:
  using Value = flutter::EncodableValue;

  void OnCall(const flutter::MethodCall<Value>& call,
              std::unique_ptr<flutter::MethodResult<Value>> result);
  void SetTray(const flutter::EncodableMap& args);
  void ApplyTray();
  void RemoveTray();
  void ShowWindowAndFocus();
  void ShowFlyout(int width, int height, int notch, bool open);
  void PlaceFlyout();
  // Back to the main window's shape. It hides the window first, which a
  // change of style needs.
  void LeaveFlyout();
  void DismissFlyout();
  POINT TrayAnchor();
  HICON MakeIcon();
  void ShowMenu();
  HMENU BuildMenu(const flutter::EncodableList& items);
  void Event(const std::string& name, Value argument = Value());

  HWND window_;
  std::unique_ptr<flutter::MethodChannel<Value>> channel_;
  bool ready_ = false;

  bool tray_added_ = false;
  HICON icon_ = nullptr;
  std::wstring tooltip_;
  // BGRA pixels by edge length, as Dart sends them.
  std::map<int, std::vector<uint8_t>> icons_;
  flutter::EncodableList menu_;
  UINT taskbar_created_;

  bool flyout_ = false;
  // Changing the size of the window makes Flutter lay itself out and the main
  // loop run, so a message can arrive in the middle of leaving the flyout.
  bool leaving_ = false;
  RECT main_rect_ = {};  // where the main window was, in pixels
  POINT anchor_ = {};    // the tray icon, in pixels
  POINT click_ = {};     // the cursor at the last tray click
  int flyout_width_ = 0, flyout_height_ = 0, flyout_notch_ = 12;  // logical
  ULONGLONG dismissed_at_ = 0;
};

#endif  // RUNNER_NATIVE_SHELL_H_
