import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

class CustomCefWebView extends StatefulWidget {
  final String url;
  const CustomCefWebView({super.key, required this.url});

  @override
  State<CustomCefWebView> createState() => _CustomCefWebViewState();
}

class _CustomCefWebViewState extends State<CustomCefWebView> {
  static const MethodChannel _channel = MethodChannel('custom_cef_webview');
  final FocusNode _focusNode = FocusNode();
  int? _textureId;
  bool _isInitialized = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomCefWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url && _isInitialized && _textureId != null) {
      _channel.invokeMethod('loadUrl', {
        'textureId': _textureId,
        'url': widget.url,
      });
    }
  }

  Future<void> _initializeCef() async {
    try {
      final int textureId = await _channel.invokeMethod('create', {'url': widget.url});
      setState(() {
        _textureId = textureId;
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Failed to create CEF browser: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeCef();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _textureId == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = MediaQuery.of(context).devicePixelRatio;
        // Send new size to CEF
        _channel.invokeMethod('setSize', {
          'textureId': _textureId,
          'width': constraints.maxWidth.toInt(),
          'height': constraints.maxHeight.toInt(),
          'scale': scale,
        });

        return Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKey: (node, event) {
            _channel.invokeMethod('onKeyEvent', {
              'textureId': _textureId,
              'type': event is RawKeyDownEvent ? 0 : 1,
              'keyCode': event.logicalKey.keyId,
              'scanCode': event.physicalKey.usbHidUsage,
              'character': event.character,
              'modifiers': (event.isShiftPressed ? 1 : 0) | 
                           (event.isControlPressed ? 2 : 0) | 
                           (event.isAltPressed ? 4 : 0),
            });
            return KeyEventResult.handled;
          },
          child: GestureDetector(
            onTap: () {
              _focusNode.requestFocus();
            },
            child: Listener(
              onPointerHover: (event) {
                _channel.invokeMethod('sendPointerEvent', {
                  'textureId': _textureId,
                  'x': event.localPosition.dx.toInt(),
                  'y': event.localPosition.dy.toInt(),
                  'scale': scale,
                  'phase': 0, // move
                });
              },
              onPointerDown: (event) {
                _channel.invokeMethod('sendPointerEvent', {
                  'textureId': _textureId,
                  'x': event.localPosition.dx.toInt(),
                  'y': event.localPosition.dy.toInt(),
                  'scale': scale,
                  'phase': 1, // down
                });
              },
              onPointerUp: (event) {
                _channel.invokeMethod('sendPointerEvent', {
                  'textureId': _textureId,
                  'x': event.localPosition.dx.toInt(),
                  'y': event.localPosition.dy.toInt(),
                  'scale': scale,
                  'phase': 2, // up
                });
              },
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  _channel.invokeMethod('sendPointerScrollEvent', {
                    'textureId': _textureId,
                    'x': event.localPosition.dx.toInt(),
                    'y': event.localPosition.dy.toInt(),
                    'scale': scale,
                    'deltaX': event.scrollDelta.dx.toInt(),
                    'deltaY': event.scrollDelta.dy.toInt(),
                  });
                }
              },
              child: Container(
                color: Colors.black,
                child: Texture(textureId: _textureId!),
              ),
            ),
          ),
        );
      },
    );
  }
}