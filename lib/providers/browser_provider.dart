import 'dart:io';
import 'package:flutter/material.dart';
import '../services/ollama_service.dart';
import '../services/local_llama_service.dart';

class BrowserTab {
  String url;
  String title;
  bool isLoading;

  BrowserTab({required this.url, this.title = 'New Tab', this.isLoading = false});
}

class BrowserProvider with ChangeNotifier {
  final OllamaService _ollamaService = OllamaService();
  final LocalLlamaService _localLlamaService = LocalLlamaService();
  
  final List<BrowserTab> _tabs = [BrowserTab(url: 'https://google.com')];
  int _currentTabIndex = 0;
  
  List<Map<String, dynamic>> _chatMessages = [];
  bool _isChatOpen = false;

  BrowserProvider() {
    if (Platform.isAndroid || Platform.isIOS) {
      _localLlamaService.initialize().then((_) => notifyListeners());
    }
  }

  List<BrowserTab> get tabs => _tabs;
  int get currentTabIndex => _currentTabIndex;
  BrowserTab get currentTab => _tabs[_currentTabIndex];
  
  List<Map<String, dynamic>> get chatMessages => _chatMessages;
  bool get isChatOpen => _isChatOpen;
  
  String get selectedModel {
    if (Platform.isAndroid || Platform.isIOS) {
      return _localLlamaService.isReady ? 'TinyLlama (Native)' : 'Initializing Native AI...';
    }
    return _ollamaService.selectedModel;
  }

  void addTab() {
    _tabs.add(BrowserTab(url: 'https://google.com'));
    _currentTabIndex = _tabs.length - 1;
    notifyListeners();
  }

  void removeTab(int index) {
    if (_tabs.length > 1) {
      _tabs.removeAt(index);
      if (_currentTabIndex >= _tabs.length) {
        _currentTabIndex = _tabs.length - 1;
      }
      notifyListeners();
    }
  }

  void selectTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  void setUrl(String url) {
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }
    currentTab.url = url;
    notifyListeners();
  }

  void setLoading(bool loading) {
    currentTab.isLoading = loading;
    notifyListeners();
  }

  void toggleChat() {
    _isChatOpen = !_isChatOpen;
    notifyListeners();
  }

  Future<void> askAI(String question, {String? base64Image}) async {
    _chatMessages.add({
      'role': 'user', 
      'content': question,
      'hasImage': base64Image != null,
      'imageData': base64Image,
    });
    notifyListeners();

    String response;
    if (Platform.isAndroid || Platform.isIOS) {
      response = await _localLlamaService.generateResponse(question);
    } else {
      response = await _ollamaService.generateResponse(question, base64Image: base64Image);
    }

    _chatMessages.add({'role': 'assistant', 'content': response});
    notifyListeners();
  }

  @override
  void dispose() {
    _localLlamaService.dispose();
    super.dispose();
  }
}