#ifndef CEF_TEXTURE_H_
#define CEF_TEXTURE_H_

#include <flutter_linux/flutter_linux.h>
#include <mutex>

G_BEGIN_DECLS

G_DECLARE_FINAL_TYPE(CefTexture, cef_texture, CEF, TEXTURE, FlPixelBufferTexture)

CefTexture* cef_texture_new();

void cef_texture_update_buffer(CefTexture* self, const void* buffer, int width, int height);

G_END_DECLS

#endif  // CEF_TEXTURE_H_
