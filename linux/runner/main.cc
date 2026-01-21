#include "my_application.h"
#include "cef_handler.h"

int main(int argc, char** argv) {
  CefMainArgs main_args(argc, argv);
  CefRefPtr<BrowserApp> app(new BrowserApp());

  // Execute the secondary process, if any.
  int exit_code = CefExecuteProcess(main_args, app.get(), nullptr);
  if (exit_code >= 0) {
    return exit_code;
  }

  CefSettings settings;
  settings.no_sandbox = true;
  settings.windowless_rendering_enabled = true;
  settings.multi_threaded_message_loop = true;
  
  // Disable accessibility to avoid Atk-CRITICAL warnings on some systems
  // settings.backend_accessibility_disabled = true; // Use appropriate flag for version

  // Set a modern User Agent for better site compatibility
  CefString(&settings.user_agent).FromASCII("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36");

  CefInitialize(main_args, settings, app.get(), nullptr);

  g_autoptr(MyApplication) flutter_app = my_application_new();
  int result = g_application_run(G_APPLICATION(flutter_app), argc, argv);

  CefShutdown();
  return result;
}
