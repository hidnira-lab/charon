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
// ("charon/window"): the frameless window (move, minimize, hide, show, quit),
// the tray icon with its tooltip and its native right click menu, and the
// events the Dart side acts on. Charon has no plugin for any of it, so this is
// all of it.
//
// Dart to native: ready, minimize, hide, show, quit, startDrag, setTray,
// removeTray. Native to Dart: closeRequested, trayLeftClick, trayDoubleClick,
// menuCommand (the id of the picked item).
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

 private:
  using Value = flutter::EncodableValue;

  void OnCall(const flutter::MethodCall<Value>& call,
              std::unique_ptr<flutter::MethodResult<Value>> result);
  void SetTray(const flutter::EncodableMap& args);
  void ApplyTray();
  void RemoveTray();
  void ShowWindowAndFocus();
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
};

#endif  // RUNNER_NATIVE_SHELL_H_
