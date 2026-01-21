import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:system_info2/system_info2.dart';

class OllamaService {
  static const String _baseUrl = 'http://localhost:11434/api';
  String _selectedModel = 'llava:7b';
  List<String> _availableModels = [];

  OllamaService() {
    _init();
  }

  Future<void> _init() async {
    await _fetchModels();
    _determineModel();
  }

  Future<void> _fetchModels() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/tags'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = data['models'] as List;
        
        _availableModels = models
            .map((m) => m['name'] as String)
            .where((name) => !name.contains('-cloud'))
            .toList();
            
        print('Available local Ollama models: $_availableModels');
      }
    } catch (e) {
      print('Error fetching models: $e');
    }
  }

  void _determineModel() {
    final totalMemoryGb = SysInfo.getTotalPhysicalMemory() / (1024 * 1024 * 1024);
    
    const highEnd = 'llama3.2-vision:11b'; 
    const midRange = 'llava:7b';
    const lowEnd = 'moondream:latest';

    String preferred;
    if (totalMemoryGb > 16) {
      preferred = highEnd;
    } else if (totalMemoryGb > 8) {
      preferred = midRange;
    } else {
      preferred = lowEnd;
    }

    if (_availableModels.contains(preferred)) {
      _selectedModel = preferred;
    } else if (_availableModels.isNotEmpty) {
      _selectedModel = _availableModels.firstWhere(
        (m) => m.contains('vision') || m.contains('llava') || m.contains('moon') || m.contains('ministral'),
        orElse: () => _availableModels.first,
      );
    } else {
      _selectedModel = preferred;
    }
    
    print('Selected local VLM: $_selectedModel');
  }

  Future<String> generateResponse(String prompt, {String? base64Image}) async {
    try {
      if (_availableModels.isEmpty) await _fetchModels();

      final Map<String, dynamic> body = {
        'model': _selectedModel,
        'prompt': prompt,
        'stream': false,
      };

      if (base64Image != null) {
        // Ollama expects raw base64 strings in a list
        body['images'] = [base64Image];
        print('Sending image to Ollama generate, base64 length: ${base64Image.length}');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      } else {
        print('Ollama error: ${response.statusCode} - ${response.body}');
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      print('Connection error: $e');
      return 'Error connecting to local Ollama: $e';
    }
  }

  String get selectedModel => _selectedModel;
}
