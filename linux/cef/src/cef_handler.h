#ifndef CEF_HANDLER_H_
#define CEF_HANDLER_H_

#include "cef_app.h"
#include "cef_client.h"
#include "cef_render_handler.h"
#include "cef_task.h"
#include "include/base/cef_callback.h"
#include "include/wrapper/cef_closure_task.h"
#include "cef_texture.h"

class BrowserHandler : public CefClient, 
                       public CefRenderHandler,
                       public CefLifeSpanHandler,
                       public CefFocusHandler {
 public:
  BrowserHandler(FlTextureRegistrar* registrar, CefTexture* texture);
  ~BrowserHandler() override;

  // CefClient methods:
  CefRefPtr<CefRenderHandler> GetRenderHandler() override { return this; }
  CefRefPtr<CefLifeSpanHandler> GetLifeSpanHandler() override { return this; }
  CefRefPtr<CefFocusHandler> GetFocusHandler() override { return this; }

  // CefLifeSpanHandler methods:
  void OnAfterCreated(CefRefPtr<CefBrowser> browser) override;

  // CefFocusHandler methods:
  void OnGotFocus(CefRefPtr<CefBrowser> browser) override;

  // CefRenderHandler methods:
  void GetViewRect(CefRefPtr<CefBrowser> browser, CefRect& rect) override;
  void OnPaint(CefRefPtr<CefBrowser> browser,
               PaintElementType type,
               const RectList& dirtyRects,
               const void* buffer,
               int width,
               int height) override;

  void SetSize(int width, int height);
  CefRefPtr<CefBrowser> GetBrowser();

 private:
  FlTextureRegistrar* registrar_;
  CefTexture* texture_;
  CefRefPtr<CefBrowser> browser_;
  int width_ = 1280;
  int height_ = 720;

  IMPLEMENT_REFCOUNTING(BrowserHandler);
};

class BrowserApp : public CefApp,
                   public CefBrowserProcessHandler,
                   public CefRenderProcessHandler {
 public:
  BrowserApp();

  // CefApp methods:
  CefRefPtr<CefBrowserProcessHandler> GetBrowserProcessHandler() override { return this; }
  CefRefPtr<CefRenderProcessHandler> GetRenderProcessHandler() override { return this; }

  // CefBrowserProcessHandler methods:
  void OnContextInitialized() override;

  IMPLEMENT_REFCOUNTING(BrowserApp);
};

#endif  // CEF_HANDLER_H_
