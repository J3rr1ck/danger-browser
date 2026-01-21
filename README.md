# DangerBrowser ⚡

DangerBrowser is a modern, high-performance web browser built with Flutter, featuring a **Neo Glassmorphic** design and **Local AI** integration. It uses a custom-built CEF (Chromium Embedded Framework) integration for Linux to provide a seamless, integrated browsing experience.

## Features 🚀

- **Neo Glassmorphic UI**: A beautiful, translucent user interface with real-time blur and vibrant accent colors.
- **Integrated Local AI**:
  - **Linux/Desktop**: Connects to local **Ollama** instances.
  - **Mobile (Android/iOS)**: Uses **Native ML** via `llama_cpp_dart`.
  - **VLM Support**: Can "see" and analyze the current page via automated screenshots passed to local Vision-Language Models (like `ministral-3:8b`, `llava`, or `llama3.2-vision`).
- **Custom CEF Integration (Linux)**: A high-performance C++ backend that renders Chromium frames directly into Flutter textures.
- **Tab Management**: Support for multiple browsing tabs.
- **Markdown Chat**: AI responses are rendered with full markdown support for code blocks and rich formatting.

## Architecture 🏗️

- **Frontend**: Flutter (Dart)
- **Linux Backend**: Custom C++ implementation using CEF (Chromium Embedded Framework).
- **Inference**: 
  - Desktop: Ollama API (Local).
  - Mobile: `llama_cpp_dart` for on-device inference.
- **Rendering**: Custom `FlTexture` implementation for OSR (Off-Screen Rendering) on Linux.

## Requirements 🛠️

### Linux Dependencies
- **Flutter SDK**: [Install Flutter](https://docs.flutter.dev/get-started/install/linux)
- **CEF SDK**: Handled automatically via `scripts/download_cef.sh`.
- **Ollama**: Must be installed and running (`ollama serve`) for AI features.
- **System Libraries**: `libgtk-3-dev`, `liblzma-dev`, `libgcrypt20-dev`, `libatk1.0-dev`.
- **Build Tools**: `clang`, `cmake`, `ninja-build`, `pkg-config`.
- **Utilities**: `xclip` (for clipboard support).

### Local AI Setup
DangerBrowser relies on a local Ollama instance. Ensure it's running:
```bash
# In a separate terminal
ollama serve
```

For full multimodal (Vision) support, pull a compatible model:
```bash
ollama pull ministral-3:8b
# or
ollama pull llama3.2-vision
```

## Build & Development 🏁

### 1. Initialize the environment
Download the required Chromium Embedded Framework SDK:
```bash
bash scripts/download_cef.sh
```

### 2. Build the C++ DLL Wrapper
This builds the necessary static library for the custom Linux backend using Clang:
```bash
bash scripts/build_cef_wrapper.sh
```

### 3. Build/Run the Flutter Application
**Debug Mode**:
```bash
flutter run -d linux
```

**Release Build**:
```bash
flutter build linux --release
```

## AppImage Build (Experimental) 📦

A GitHub Action is provided to automatically generate AppImages on every push to the `master` branch. You can find the artifacts in the "Actions" tab of your repository.

## Local AI Configuration 🧠

The browser intelligently selects models based on your available system RAM:
- **> 16GB**: Prioritizes `llama3.2-vision:11b`
- **> 8GB**: Prioritizes `llava:7b` or `ministral-3:8b`
- **Fallback**: Automatically finds any available vision-capable local model.

## License 📄

Developed by the Danger Team.