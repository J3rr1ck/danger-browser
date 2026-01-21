#include "cef_handler.h"
#include <iostream>

BrowserHandler::BrowserHandler(FlTextureRegistrar* registrar, CefTexture* texture)
    : registrar_(registrar), texture_(texture), browser_(nullptr) {}

BrowserHandler::~BrowserHandler() {}

void BrowserHandler::OnAfterCreated(CefRefPtr<CefBrowser> browser) {
  browser_ = browser;
}

void BrowserHandler::OnGotFocus(CefRefPtr<CefBrowser> browser) {
  // Can be used for debugging focus flow
}

CefRefPtr<CefBrowser> BrowserHandler::GetBrowser() {
  return browser_;
}

void BrowserHandler::GetViewRect(CefRefPtr<CefBrowser> browser, CefRect& rect) {
  rect.Set(0, 0, width_, height_);
}

void BrowserHandler::OnPaint(CefRefPtr<CefBrowser> browser,
                             PaintElementType type,
                             const RectList& dirtyRects,
                             const void* buffer,
                             int width,
                             int height) {
  cef_texture_update_buffer(texture_, buffer, width, height);
  fl_texture_registrar_mark_texture_frame_available(registrar_, FL_TEXTURE(texture_));
}

void BrowserHandler::SetSize(int width, int height) {
  width_ = width;
  height_ = height;
}

BrowserApp::BrowserApp() {}

void BrowserApp::OnContextInitialized() {}