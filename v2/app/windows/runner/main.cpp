#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include <shellapi.h>

#include <string>

#include "flutter_window.h"
#include "native_shell.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // One Charon window per user session. A second launch brings the first one
  // forward, also when it is hidden in the tray.
  // The handle is kept open until the process ends: that is what holds the name.
  [[maybe_unused]] ::HANDLE single = ::CreateMutexW(nullptr, TRUE, L"Local\\Charon.v2.Window");
  if (::GetLastError() == ERROR_ALREADY_EXISTS) {
    if (HWND other = ::FindWindowW(L"FLUTTER_RUNNER_WIN32_WINDOW", L"Charon")) {
      // A button of a toast starts the program with a link. Hand it to the window
      // that is there, which decides what it means, and let it take the focus
      // (this process was started by the user's click, which gives that right).
      int argc = 0;
      wchar_t** argv = ::CommandLineToArgvW(::GetCommandLineW(), &argc);
      std::wstring link;
      if (argv && argc > 1 && std::wstring(argv[1]).rfind(L"charon://", 0) == 0) {
        link = argv[1];
      }
      if (argv) ::LocalFree(argv);
      if (!link.empty()) {
        ::AllowSetForegroundWindow(ASFW_ANY);
        COPYDATASTRUCT data = {};
        data.dwData = kActivationData;
        data.cbData = static_cast<DWORD>((link.size() + 1) * sizeof(wchar_t));
        data.lpData = const_cast<wchar_t*>(link.c_str());
        ::SendMessageW(other, WM_COPYDATA, 0, reinterpret_cast<LPARAM>(&data));
      } else {
        ::ShowWindow(other, ::IsIconic(other) ? SW_RESTORE : SW_SHOW);
        ::SetForegroundWindow(other);
      }
    }
    return EXIT_SUCCESS;
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  // In the middle of the screen the window opens on.
  const UINT dpi = ::GetDpiForSystem();
  const double scale = dpi / 96.0;
  const int screen_w = static_cast<int>(::GetSystemMetrics(SM_CXSCREEN) / scale);
  const int screen_h = static_cast<int>(::GetSystemMetrics(SM_CYSCREEN) / scale);
  Win32Window::Point origin(
      static_cast<unsigned int>(screen_w > 1024 ? (screen_w - 1024) / 2 : 0),
      static_cast<unsigned int>(screen_h > 768 ? (screen_h - 768) / 2 : 0));
  Win32Window::Size size(1024, 768);
  if (!window.Create(L"Charon", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
