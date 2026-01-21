#ifndef CEF_MANAGER_H_
#define CEF_MANAGER_H_

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include "cef_handler.h"
#include <map>

extern "C" gboolean processKeyEventForCEF(GtkWidget* widget, GdkEventKey* event, gpointer data);

class CefManager {
 public:
  static CefManager* GetInstance();

  void HandleMethodCall(FlMethodCall* method_call);
  
  void SetTextureRegistrar(FlTextureRegistrar* registrar) { registrar_ = registrar; }
  void SetParentWindow(GtkWindow* window) { parent_window_ = window; }

  bool OnKeyEvent(GdkEventKey* event);

 private:
  CefManager();
  static CefManager* instance_;

  void CreateBrowser(FlMethodCall* method_call);
  void SetSize(FlMethodCall* method_call);
  void LoadUrl(FlMethodCall* method_call);
  void SendPointerEvent(FlMethodCall* method_call);
  void SendPointerScrollEvent(FlMethodCall* method_call);
  void OnKeyEventFromDart(FlMethodCall* method_call);
  
  FlTextureRegistrar* registrar_;
  GtkWindow* parent_window_ = nullptr;
  std::map<int64_t, CefRefPtr<CefBrowser>> browsers_;
  std::map<int64_t, BrowserHandler*> handlers_;
};

#endif  // CEF_MANAGER_H_
