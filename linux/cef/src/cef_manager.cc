#include "cef_manager.h"
#include "cef_key_mapping.h"
#include <iostream>
#include <gtk/gtk.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

extern "C" gboolean processKeyEventForCEF(GtkWidget* widget, GdkEventKey* event, gpointer data) {
  return CefManager::GetInstance()->OnKeyEvent(event);
}

CefManager* CefManager::instance_ = nullptr;

CefManager* CefManager::GetInstance() {
  if (!instance_) {
    instance_ = new CefManager();
  }
  return instance_;
}

CefManager::CefManager() : registrar_(nullptr) {}

static int GetCefModifiers(guint state) {
  int modifiers = 0;
  if (state & GDK_SHIFT_MASK) modifiers |= EVENTFLAG_SHIFT_DOWN;
  if (state & GDK_CONTROL_MASK) modifiers |= EVENTFLAG_CONTROL_DOWN;
  if (state & GDK_MOD1_MASK) modifiers |= EVENTFLAG_ALT_DOWN;
  return modifiers;
}

static int MapLogicalToWindowsKey(int64_t key_code) {
  if (key_code >= 0x20 && key_code <= 0x7E) {
    if (key_code >= 'a' && key_code <= 'z') return key_code - 'a' + 'A';
    return (int)key_code;
  }
  int64_t masked = key_code & 0xFFFFFFFF;
  switch (masked) {
    case 0x08: return 0x08;
    case 0x09: return 0x09;
    case 0x0d: return 0x0D;
    case 0x1b: return 0x1B;
    case 0x20: return 0x20;
    case 0x25: return 0x25;
    case 0x26: return 0x26;
    case 0x27: return 0x27;
    case 0x28: return 0x28;
    case 0x2e: return 0x2E;
    default: return (int)masked;
  }
}

bool CefManager::OnKeyEvent(GdkEventKey* event) {
  return FALSE; // Deprecated by OnKeyEventFromDart
}

void CefManager::HandleMethodCall(FlMethodCall* method_call) {
  const gchar* method = fl_method_call_get_name(method_call);
  if (strcmp(method, "create") == 0) {
    CreateBrowser(method_call);
  } else if (strcmp(method, "setSize") == 0) {
    SetSize(method_call);
  } else if (strcmp(method, "loadUrl") == 0) {
    LoadUrl(method_call);
  } else if (strcmp(method, "sendPointerEvent") == 0) {
    SendPointerEvent(method_call);
  } else if (strcmp(method, "sendPointerScrollEvent") == 0) {
    SendPointerScrollEvent(method_call);
  } else if (strcmp(method, "onKeyEvent") == 0) {
    OnKeyEventFromDart(method_call);
  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}

void CefManager::OnKeyEventFromDart(FlMethodCall* method_call) {
  FlValue* args = fl_method_call_get_args(method_call);
  int64_t texture_id = fl_value_get_int(fl_value_lookup_string(args, "textureId"));
  int type = fl_value_get_int(fl_value_lookup_string(args, "type"));
  int64_t key_code = fl_value_get_int(fl_value_lookup_string(args, "keyCode"));
  int64_t scan_code = fl_value_get_int(fl_value_lookup_string(args, "scanCode"));
  int64_t modifiers = fl_value_get_int(fl_value_lookup_string(args, "modifiers"));
  
  FlValue* char_val = fl_value_lookup_string(args, "character");
  const gchar* character = (char_val && fl_value_get_type(char_val) == FL_VALUE_TYPE_STRING) 
                           ? fl_value_get_string(char_val) 
                           : nullptr;

  if (handlers_.count(texture_id)) {
    auto browser = handlers_[texture_id]->GetBrowser();
    if (browser) {
      CefKeyEvent cef_event;
      cef_event.modifiers = modifiers;
      cef_event.native_key_code = (int)scan_code;
      cef_event.windows_key_code = MapLogicalToWindowsKey(key_code);

      CefPostTask(TID_UI, CefCreateClosureTask(base::BindOnce([](CefRefPtr<CefBrowser> browser, CefKeyEvent cef_event, int type, std::string char_str) {
        browser->GetHost()->SetFocus(true);
        
        if (type == 0) {
          cef_event.type = KEYEVENT_RAWKEYDOWN;
          browser->GetHost()->SendKeyEvent(cef_event);
          
          if (!char_str.empty()) {
            uint32_t char_code = (uint32_t)char_str[0];
            cef_event.type = KEYEVENT_CHAR;
            cef_event.windows_key_code = char_code;
            cef_event.character = char_code;
            cef_event.unmodified_character = char_code;
            browser->GetHost()->SendKeyEvent(cef_event);
          }
        } else {
          cef_event.type = KEYEVENT_KEYUP;
          browser->GetHost()->SendKeyEvent(cef_event);
        }
      }, browser, cef_event, type, character ? std::string(character) : "")));
      fl_method_call_respond_success(method_call, nullptr, nullptr);
      return;
    }
  }
  fl_method_call_respond_error(method_call, "failed", "Could not send key event", nullptr, nullptr);
}

void CefManager::SendPointerEvent(FlMethodCall* method_call) {
  FlValue* args = fl_method_call_get_args(method_call);
  int64_t texture_id = fl_value_get_int(fl_value_lookup_string(args, "textureId"));
  int64_t x = fl_value_get_int(fl_value_lookup_string(args, "x"));
  int64_t y = fl_value_get_int(fl_value_lookup_string(args, "y"));
  double scale = fl_value_get_float(fl_value_lookup_string(args, "scale"));
  int64_t phase = fl_value_get_int(fl_value_lookup_string(args, "phase"));

  if (handlers_.count(texture_id)) {
    auto browser = handlers_[texture_id]->GetBrowser();
    if (browser) {
      CefMouseEvent mouse_event;
      mouse_event.x = x * scale;
      mouse_event.y = y * scale;
      CefPostTask(TID_UI, CefCreateClosureTask(base::BindOnce([](CefRefPtr<CefBrowser> browser, CefMouseEvent mouse_event, int64_t phase) {
        if (phase == 0) {
          browser->GetHost()->SendMouseMoveEvent(mouse_event, false);
        } else if (phase == 1) {
          browser->GetHost()->SetFocus(true);
          browser->GetHost()->SendMouseClickEvent(mouse_event, MBT_LEFT, false, 1);
        } else if (phase == 2) {
          browser->GetHost()->SendMouseClickEvent(mouse_event, MBT_LEFT, true, 1);
        }
      }, browser, mouse_event, phase)));
      fl_method_call_respond_success(method_call, nullptr, nullptr);
      return;
    }
  }
  fl_method_call_respond_error(method_call, "failed", "Could not send event", nullptr, nullptr);
}

void CefManager::SendPointerScrollEvent(FlMethodCall* method_call) {
  FlValue* args = fl_method_call_get_args(method_call);
  int64_t texture_id = fl_value_get_int(fl_value_lookup_string(args, "textureId"));
  int64_t x = fl_value_get_int(fl_value_lookup_string(args, "x"));
  int64_t y = fl_value_get_int(fl_value_lookup_string(args, "y"));
  double scale = fl_value_get_float(fl_value_lookup_string(args, "scale"));
  int64_t delta_x = fl_value_get_int(fl_value_lookup_string(args, "deltaX"));
  int64_t delta_y = fl_value_get_int(fl_value_lookup_string(args, "deltaY"));

  if (handlers_.count(texture_id)) {
    auto browser = handlers_[texture_id]->GetBrowser();
    if (browser) {
      CefMouseEvent mouse_event;
      mouse_event.x = x * scale;
      mouse_event.y = y * scale;
      
      // Invert deltas: Flutter down is +dy, CEF down is -dy
      int dx = (int)(delta_x * scale);
      int dy = (int)(-delta_y * scale); 

      CefPostTask(TID_UI, CefCreateClosureTask(base::BindOnce([](CefRefPtr<CefBrowser> browser, CefMouseEvent mouse_event, int dx, int dy) {
        browser->GetHost()->SendMouseWheelEvent(mouse_event, dx, dy);
      }, browser, mouse_event, dx, dy)));
      
      fl_method_call_respond_success(method_call, nullptr, nullptr);
      return;
    }
  }
  fl_method_call_respond_error(method_call, "failed", "Could not send event", nullptr, nullptr);
}

void CefManager::LoadUrl(FlMethodCall* method_call) {
  FlValue* args = fl_method_call_get_args(method_call);
  int64_t texture_id = fl_value_get_int(fl_value_lookup_string(args, "textureId"));
  const gchar* url = fl_value_get_string(fl_value_lookup_string(args, "url"));
  if (handlers_.count(texture_id)) {
    auto browser = handlers_[texture_id]->GetBrowser();
    if (browser) {
      browser->GetMainFrame()->LoadURL(url);
      fl_method_call_respond_success(method_call, nullptr, nullptr);
    } else {
      fl_method_call_respond_error(method_call, "not_ready", "Browser not yet created", nullptr, nullptr);
    }
  } else {
    fl_method_call_respond_error(method_call, "not_found", "Handler not found", nullptr, nullptr);
  }
}

void CefManager::CreateBrowser(FlMethodCall* method_call) {
  FlValue* args = fl_method_call_get_args(method_call);
  const gchar* url = fl_value_get_string(fl_value_lookup_string(args, "url"));
  CefTexture* texture = cef_texture_new();
  fl_texture_registrar_register_texture(registrar_, FL_TEXTURE(texture));
  int64_t texture_id = fl_texture_get_id(FL_TEXTURE(texture));
  CefWindowInfo window_info;
  window_info.SetAsWindowless(0);
  CefBrowserSettings browser_settings;
  CefRefPtr<BrowserHandler> handler(new BrowserHandler(registrar_, texture));
  handlers_[texture_id] = handler.get();
  bool success = CefBrowserHost::CreateBrowser(window_info, handler, url, browser_settings, nullptr, nullptr);
  if (success) {
    g_autoptr(FlValue) result = fl_value_new_int(texture_id);
    fl_method_call_respond_success(method_call, result, nullptr);
  } else {
    fl_method_call_respond_error(method_call, "create_failed", "Failed to initiate CEF browser creation", nullptr, nullptr);
  }
}

void CefManager::SetSize(FlMethodCall* method_call) {
  FlValue* args = fl_method_call_get_args(method_call);
  int64_t texture_id = fl_value_get_int(fl_value_lookup_string(args, "textureId"));
  int64_t width = fl_value_get_int(fl_value_lookup_string(args, "width"));
  int64_t height = fl_value_get_int(fl_value_lookup_string(args, "height"));
  double scale = fl_value_get_float(fl_value_lookup_string(args, "scale"));
  if (handlers_.count(texture_id)) {
    handlers_[texture_id]->SetSize(width * scale, height * scale);
    auto browser = handlers_[texture_id]->GetBrowser();
    if (browser) {
      CefPostTask(TID_UI, CefCreateClosureTask(base::BindOnce([](CefRefPtr<CefBrowser> browser) {
        browser->GetHost()->WasResized();
      }, browser)));
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
  } else {
    fl_method_call_respond_error(method_call, "not_found", "Handler not found for textureId", nullptr, nullptr);
  }
}
