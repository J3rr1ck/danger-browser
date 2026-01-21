import 'dart:io';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image/image.dart' as img;
import 'custom_cef_webview.dart';
import '../providers/browser_provider.dart';
import 'glass_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Map<int, InAppWebViewController> _controllers = {};
  final TextEditingController _urlController = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BrowserProvider>();
    _urlController.text = provider.currentTab.url;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildTabBar(provider),
                _buildUrlBar(provider),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      child: Screenshot(
                        controller: _screenshotController,
                        child: _buildWebView(provider),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (provider.isChatOpen) _buildAIChat(provider),

          Positioned(
            bottom: 30,
            right: 30,
            child: _buildGlassButton(
              onPressed: () => provider.toggleChat(),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 30),
            ).animate().scale(delay: 500.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildWebView(BrowserProvider provider) {
    if (Platform.isAndroid || Platform.isIOS) {
      return InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(provider.currentTab.url)),
        onWebViewCreated: (controller) {
          _controllers[provider.currentTabIndex] = controller;
        },
        onLoadStart: (controller, url) {
          provider.setLoading(true);
          if (url != null) {
            provider.setUrl(url.toString());
          }
        },
        onLoadStop: (controller, url) {
          provider.setLoading(false);
        },
      );
    } else if (Platform.isLinux) {
      return CustomCefWebView(url: provider.currentTab.url);
    } else {
      return Container(
        color: Colors.white.withOpacity(0.05),
        child: const Center(
          child: Text('Platform not supported', style: TextStyle(color: Colors.white)),
        ),
      );
    }
  }

  Widget _buildTabBar(BrowserProvider provider) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.tabs.length + 1,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          if (index == provider.tabs.length) {
            return IconButton(
              icon: const Icon(Icons.add, color: Colors.white70),
              onPressed: () => provider.addTab(),
            );
          }

          final isSelected = provider.currentTabIndex == index;
          return GestureDetector(
            onTap: () => provider.selectTab(index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              child: GlassmorphicContainer(
                width: 150,
                height: 40,
                borderRadius: 12,
                blur: 10,
                alignment: Alignment.center,
                border: isSelected ? 2 : 1,
                linearGradient: LinearGradient(
                  colors: isSelected 
                    ? [GlassTheme.accentColor.withOpacity(0.3), GlassTheme.accentColor.withOpacity(0.1)]
                    : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                ),
                borderGradient: LinearGradient(
                  colors: isSelected 
                    ? [GlassTheme.accentColor, Colors.white24]
                    : [Colors.white24, Colors.white10],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          provider.tabs[index].url.replaceFirst('https://', ''),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 12,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (provider.tabs.length > 1)
                        GestureDetector(
                          onTap: () => provider.removeTab(index),
                          child: const Icon(Icons.close, size: 14, color: Colors.white70),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUrlBar(BrowserProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 60,
        borderRadius: 20,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
        ),
        borderGradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.5), Colors.white.withOpacity(0.2)],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.lock_outline, color: Colors.white54, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _urlController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search or enter URL',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  onSubmitted: (value) {
                    provider.setUrl(value);
                    FocusScope.of(context).unfocus(); // Release focus from address bar
                    if (Platform.isAndroid || Platform.isIOS) {
                      _controllers[provider.currentTabIndex]?.loadUrl(
                        urlRequest: URLRequest(url: WebUri(provider.currentTab.url))
                      );
                    }
                    // For Linux, CustomCefWebView will react to provider.setUrl update via didUpdateWidget
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined, color: Colors.white70),
                onPressed: () async {
                  await Future.delayed(const Duration(milliseconds: 100));
                  final image = await _screenshotController.capture(pixelRatio: 2.0);
                  if (image != null) {
                    // Compress to JPEG
                    final decodedImage = img.decodeImage(image);
                    if (decodedImage != null) {
                      final compressedImage = img.encodeJpg(decodedImage, quality: 80);
                      final base64Image = base64Encode(compressedImage);
                      if (!provider.isChatOpen) provider.toggleChat();
                      provider.askAI("Describe this browser view in detail and summarize the content.", base64Image: base64Image);
                    }
                  }
                },
              ),
              if (provider.currentTab.isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: GlassTheme.accentColor),
                ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () {
                  if (Platform.isAndroid || Platform.isIOS) {
                    _controllers[provider.currentTabIndex]?.reload();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton({required VoidCallback onPressed, required Widget child}) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            padding: const EdgeInsets.all(12),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildAIChat(BrowserProvider provider) {
    return Positioned.fill(
      child: Container(
        color: Colors.black26,
        child: Center(
          child: GlassmorphicContainer(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.7,
            borderRadius: 30,
            blur: 25,
            alignment: Alignment.center,
            border: 2,
            linearGradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.6)],
            ),
            borderGradient: LinearGradient(
              colors: [GlassTheme.accentColor.withOpacity(0.5), Colors.white.withOpacity(0.2)],
            ),
            child: Column(
              children: [
                _buildChatHeader(provider),
                Expanded(child: _buildChatList(provider)),
                _buildChatInput(provider),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(),
    );
  }

  Widget _buildChatHeader(BrowserProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: GlassTheme.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome, color: GlassTheme.accentColor),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Local VLM Assistant', style: GlassTheme.titleStyle.copyWith(fontSize: 18)),
              Text('Model: ${provider.selectedModel}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => provider.toggleChat(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(BrowserProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: provider.chatMessages.length,
      itemBuilder: (context, index) {
        final msg = provider.chatMessages[index];
        final isUser = msg['role'] == 'user';
        final hasImage = msg['hasImage'] == true;
        final imageData = msg['imageData'] as String?;

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (hasImage && imageData != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      base64Decode(imageData),
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(16),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
                decoration: BoxDecoration(
                  color: isUser ? GlassTheme.accentColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 0),
                    bottomRight: Radius.circular(isUser ? 0 : 20),
                  ),
                  border: Border.all(
                    color: isUser ? GlassTheme.accentColor.withOpacity(0.3) : Colors.white10,
                  ),
                ),
                child: MarkdownBody(
                  data: msg['content'] ?? '',
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(color: Colors.white, fontSize: 14),
                    code: TextStyle(
                      color: GlassTheme.accentColor,
                      backgroundColor: Colors.black.withOpacity(0.3),
                      fontFamily: 'monospace',
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).animate().slideX(begin: isUser ? 0.2 : -0.2, end: 0).fadeIn();
      },
    );
  }

  Widget _buildChatInput(BrowserProvider provider) {
    final controller = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 60,
        borderRadius: 20,
        blur: 10,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)],
        ),
        borderGradient: LinearGradient(
          colors: [Colors.white10, Colors.white10],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Type your question...',
                    hintStyle: TextStyle(color: Colors.white30),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      provider.askAI(value);
                      controller.clear();
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: GlassTheme.accentColor),
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    provider.askAI(controller.text);
                    controller.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
