
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class PrivacyPolicy extends StatelessWidget {
  final String privacyPolicy;
  const PrivacyPolicy({super.key, required this.privacyPolicy});

  @override
  Widget build(BuildContext context) {
    late final WebViewController _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(privacyPolicy);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}
