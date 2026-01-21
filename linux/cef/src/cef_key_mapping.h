#ifndef CEF_KEY_MAPPING_H_
#define CEF_KEY_MAPPING_H_

#include <gtk/gtk.h>
#include <gdk/gdkkeysyms.h>
#include "include/internal/cef_types.h"

enum KeyboardCode {
  VKEY_BACK = 0x08,
  VKEY_TAB = 0x09,
  VKEY_RETURN = 0x0D,
  VKEY_SHIFT = 0x10,
  VKEY_CONTROL = 0x11,
  VKEY_MENU = 0x12,
  VKEY_ESCAPE = 0x1B,
  VKEY_SPACE = 0x20,
  VKEY_PRIOR = 0x21,
  VKEY_NEXT = 0x22,
  VKEY_END = 0x23,
  VKEY_HOME = 0x24,
  VKEY_LEFT = 0x25,
  VKEY_UP = 0x26,
  VKEY_RIGHT = 0x27,
  VKEY_DOWN = 0x28,
  VKEY_DELETE = 0x2E,
  VKEY_0 = 0x30,
  VKEY_1 = 0x31,
  VKEY_2 = 0x32,
  VKEY_3 = 0x33,
  VKEY_4 = 0x34,
  VKEY_5 = 0x35,
  VKEY_6 = 0x36,
  VKEY_7 = 0x37,
  VKEY_8 = 0x38,
  VKEY_9 = 0x39,
  VKEY_A = 0x41,
  VKEY_B = 0x42,
  VKEY_C = 0x43,
  VKEY_D = 0x44,
  VKEY_E = 0x45,
  VKEY_F = 0x46,
  VKEY_G = 0x47,
  VKEY_H = 0x48,
  VKEY_I = 0x49,
  VKEY_J = 0x4A,
  VKEY_K = 0x4B,
  VKEY_L = 0x4C,
  VKEY_M = 0x4D,
  VKEY_N = 0x4E,
  VKEY_O = 0x4F,
  VKEY_P = 0x50,
  VKEY_Q = 0x51,
  VKEY_R = 0x52,
  VKEY_S = 0x53,
  VKEY_T = 0x54,
  VKEY_U = 0x55,
  VKEY_V = 0x56,
  VKEY_W = 0x57,
  VKEY_X = 0x58,
  VKEY_Y = 0x59,
  VKEY_Z = 0x5A,
};

inline KeyboardCode KeyboardCodeFromXKeysym(unsigned int keysym) {
  if (keysym >= GDK_KEY_a && keysym <= GDK_KEY_z)
    return static_cast<KeyboardCode>(VKEY_A + (keysym - GDK_KEY_a));
  if (keysym >= GDK_KEY_A && keysym <= GDK_KEY_Z)
    return static_cast<KeyboardCode>(VKEY_A + (keysym - GDK_KEY_A));
  if (keysym >= GDK_KEY_0 && keysym <= GDK_KEY_9)
    return static_cast<KeyboardCode>(VKEY_0 + (keysym - GDK_KEY_0));

  switch (keysym) {
    case GDK_KEY_BackSpace: return VKEY_BACK;
    case GDK_KEY_Delete: return VKEY_DELETE;
    case GDK_KEY_Tab: return VKEY_TAB;
    case GDK_KEY_Return: return VKEY_RETURN;
    case GDK_KEY_space: return VKEY_SPACE;
    case GDK_KEY_Home: return VKEY_HOME;
    case GDK_KEY_End: return VKEY_END;
    case GDK_KEY_Page_Up: return VKEY_PRIOR;
    case GDK_KEY_Page_Down: return VKEY_NEXT;
    case GDK_KEY_Left: return VKEY_LEFT;
    case GDK_KEY_Right: return VKEY_RIGHT;
    case GDK_KEY_Down: return VKEY_DOWN;
    case GDK_KEY_Up: return VKEY_UP;
    case GDK_KEY_Escape: return VKEY_ESCAPE;
    case GDK_KEY_Shift_L:
    case GDK_KEY_Shift_R: return VKEY_SHIFT;
    case GDK_KEY_Control_L:
    case GDK_KEY_Control_R: return VKEY_CONTROL;
    case GDK_KEY_Alt_L:
    case GDK_KEY_Alt_R: return VKEY_MENU;
    default: return static_cast<KeyboardCode>(0);
  }
}

inline int GetCefStateModifiers(guint state) {
  int modifiers = 0;
  if (state & GDK_SHIFT_MASK) modifiers |= EVENTFLAG_SHIFT_DOWN;
  if (state & GDK_CONTROL_MASK) modifiers |= EVENTFLAG_CONTROL_DOWN;
  if (state & GDK_MOD1_MASK) modifiers |= EVENTFLAG_ALT_DOWN;
  return modifiers;
}

#endif
