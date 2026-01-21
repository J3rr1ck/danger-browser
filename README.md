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

### Linux
- **Flutter SDK**
- **CEF SDK** (handled by `scripts/download_cef.sh`)
- **Ollama** (for AI features)
- **xclip** (for clipboard support)
- **Clang/LLVM** (for building the custom C++ backend)

### AI Models
For full vision support, ensure you have a VLM pulled in Ollama:
```bash
ollama pull ministral-3:8b
# or
ollama pull llama3.2-vision
```

## Getting Started 🏁

1. **Download CEF SDK**:
   ```bash
   bash scripts/download_cef.sh
   ```
2. **Build CEF Wrapper**:
   ```bash
   bash scripts/build_cef_wrapper.sh
   ```
3. **Run the App**:
   ```bash
   flutter run -d linux
   ```

## Local AI Configuration 🧠

The browser intelligently selects models based on your available system RAM:
- **> 16GB**: Prioritizes `llama3.2-vision:11b`
- **> 8GB**: Prioritizes `llava:7b` or `ministral-3:8b`
- **Fallback**: Automatically finds any available vision-capable local model.

## License 📄

Developed by the Danger Team.