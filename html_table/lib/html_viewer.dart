import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

class HtmlViewer extends StatefulWidget {
  const HtmlViewer({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HtmlViewerState createState() => _HtmlViewerState();
}

class _HtmlViewerState extends State<HtmlViewer> {
  late final WebViewController _controller;
  double _webViewHeight = 400;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _adjustWebViewHeight();
          },
        ),
      )
      ..addJavaScriptChannel(
        "Resize",
        onMessageReceived: (JavaScriptMessage message) {
          double newHeight = double.tryParse(message.message) ?? 400;
          setState(() {
            _webViewHeight = newHeight;
          });
        },
      )
      ..loadFlutterAsset("assets/sample.html");
  }

  Future<void> _adjustWebViewHeight() async {
    try {
      await _controller.runJavaScript("""
        Resize.postMessage(document.body.scrollHeight);
      """);
    } catch (e) {
      // print("Error adjusting height: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Auto-Resizing WebView")),
      body: SingleChildScrollView(  // To handle content overflow
        child: Column(
          children: [
            const Text("Starting of the content"),
            SizedBox(
              height: _webViewHeight,  // Fixed height for WebView
              child: WebViewWidget(controller: _controller),
            ),
            const Text("Ending of the content"),
          ],
        ),
      ),
    );
  }
}
