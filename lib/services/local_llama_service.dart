import 'dart:io';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

class LocalLlamaService {
  Llama? _llama;
  bool _isInitializing = false;
  double _downloadProgress = 0;

  bool get isReady => _llama != null;
  bool get isInitializing => _isInitializing;
  double get downloadProgress => _downloadProgress;

  Future<void> initialize() async {
    if (_llama != null || _isInitializing) return;
    _isInitializing = true;

    try {
      final directory = await getApplicationSupportDirectory();
      final modelPath = p.join(directory.path, 'tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf');

      if (!File(modelPath).existsSync()) {
        await _downloadModel(modelPath);
      }

      final modelParams = ModelParams();
      if (Platform.isAndroid || Platform.isIOS) {
        modelParams.nGpuLayers = 32;
      }

      final contextParams = ContextParams();
      contextParams.nCtx = 2048;

      _llama = Llama(
        modelPath, 
        modelParams: modelParams, 
        contextParams: contextParams,
      );
    } catch (e) {
      print('Error initializing Local Llama: $e');
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _downloadModel(String path) async {
    const url = 'https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf';
    final dio = Dio();
    await dio.download(
      url,
      path,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          _downloadProgress = received / total;
        }
      },
    );
  }

  Future<String> generateResponse(String prompt) async {
    if (_llama == null) return 'Local AI is not ready yet.';

    try {
      // Fixed multiline string with triple quotes
      final formattedPrompt = '''<|system|>
You are a helpful browser assistant.</s>
<|user|>
$prompt</s>
<|assistant|>
''';
      
      _llama!.setPrompt(formattedPrompt);
      return await _llama!.generateCompleteText();
    } catch (e) {
      return 'Error generating response: $e';
    }
  }

  void dispose() {
    _llama?.dispose();
  }
}