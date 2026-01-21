#include "cef_texture.h"
#include <cstdlib>
#include <cstring>

struct _CefTexture {
  FlPixelBufferTexture parent_instance;
  uint8_t* buffer;
  uint32_t width;
  uint32_t height;
  std::mutex mutex;
};

G_DEFINE_TYPE(CefTexture, cef_texture, fl_pixel_buffer_texture_get_type())

static void cef_texture_dispose(GObject* object) {
  CefTexture* self = CEF_TEXTURE(object);
  if (self->buffer) {
    free(self->buffer);
    self->buffer = nullptr;
  }
  G_OBJECT_CLASS(cef_texture_parent_class)->dispose(object);
}

static gboolean cef_texture_copy_pixels(FlPixelBufferTexture* texture,
                                        const uint8_t** out_buffer,
                                        uint32_t* width,
                                        uint32_t* height,
                                        GError** error) {
  CefTexture* self = CEF_TEXTURE(texture);
  std::lock_guard<std::mutex> lock(self->mutex);

  if (self->buffer && self->width > 0 && self->height > 0) {
    *out_buffer = self->buffer;
    *width = self->width;
    *height = self->height;
    return TRUE;
  }

  // Returning FALSE here tells Flutter there is no frame available yet
  return FALSE;
}

static void cef_texture_class_init(CefTextureClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = cef_texture_dispose;
  FL_PIXEL_BUFFER_TEXTURE_CLASS(klass)->copy_pixels = cef_texture_copy_pixels;
}

static void cef_texture_init(CefTexture* self) {
  self->buffer = nullptr;
  self->width = 0;
  self->height = 0;
}

CefTexture* cef_texture_new() {
  return CEF_TEXTURE(g_object_new(cef_texture_get_type(), nullptr));
}

void cef_texture_update_buffer(CefTexture* self, const void* buffer, int width, int height) {
  if (!buffer || width <= 0 || height <= 0) return;
  std::lock_guard<std::mutex> lock(self->mutex);

  size_t size = (size_t)width * (size_t)height * 4;
  if (self->width != (uint32_t)width || self->height != (uint32_t)height || !self->buffer) {
    uint8_t* new_buffer = (uint8_t*)realloc(self->buffer, size);
    if (!new_buffer) return;
    self->buffer = new_buffer;
    self->width = width;
    self->height = height;
  }

  if (self->buffer) {
    const uint8_t* src = (const uint8_t*)buffer;
    uint8_t* dst = self->buffer;
    
    // CEF provides BGRA, Flutter expects RGBA
    // Optimized loop for color conversion
    for (size_t i = 0; i < size; i += 4) {
      dst[i] = src[i + 2];     // R
      dst[i + 1] = src[i + 1]; // G
      dst[i + 2] = src[i];     // B
      dst[i + 3] = src[i + 3]; // A
    }
  }
}
