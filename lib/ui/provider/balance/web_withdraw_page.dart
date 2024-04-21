import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebWithdrawPage extends StatelessWidget {
  final String url;

  const WebWithdrawPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WebViewController webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if(didPop){
            return;
          }
          await Navigator.pushReplacementNamed(context, "/provider/balance");
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () async {
                await Navigator.pushReplacementNamed(context, "/provider/balance");
              },
            ),
            title: Text("Pengambilan Saldo"),
          ),
          body: WebViewWidget(
              controller: webViewController..loadRequest(Uri.parse(url))),
        ));
  }
}
