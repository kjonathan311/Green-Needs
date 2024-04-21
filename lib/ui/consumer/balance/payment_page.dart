
import 'package:flutter/material.dart';
import 'package:greenneeds/ui/consumer/balance/consumer_balance_view_model.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentPage extends StatelessWidget {
  final String url;

  const PaymentPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final balanceViewModel = Provider.of<ConsumerBalanceViewModel>(context);
    WebViewController webViewController =
    WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if(didPop){
          return;
        }
        await balanceViewModel.getPaymentStatus(context);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              await balanceViewModel.getPaymentStatus(context);
            },
          ),
          title: Text("Pembayaran Saldo"),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: webViewController..loadRequest(Uri.parse(url))),
            if (balanceViewModel.isLoading)
              Container(
                color: Colors.black.withOpacity(0.1),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
          ],
        ),
      ),
    );
  }
}
