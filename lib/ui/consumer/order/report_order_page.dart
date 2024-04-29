
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/OrderItem.dart';
import '../../utils.dart';
import 'consumer_order_view_model.dart';

class ReportOrderPage extends StatefulWidget {
  final OrderItemWithProviderAndConsumer transaction;

  const ReportOrderPage({super.key, required this.transaction});

  @override
  State<ReportOrderPage> createState() => _ReportOrderPageState();
}

class _ReportOrderPageState extends State<ReportOrderPage> {
  final TextEditingController _commentController = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    if(widget.transaction.order.reportReason!=null) {
      _commentController.text = widget.transaction.order.reportReason!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final consumerOrderViewModel = Provider.of<ConsumerOrderViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lapor Order"),
        actions: [
          IconButton(onPressed: ()async {
          if(_imageFile!=null && _commentController.text.isNotEmpty){
            await consumerOrderViewModel.reportOrder(widget.transaction, _imageFile!, _commentController.text.trim());
            Navigator.pop(context);
          }else{
          showCustomSnackBar(context, "Semua field harus diisi.", color: Colors.red);
          }
          }, icon: Icon(Icons.report_problem))
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("lapor order jikalau order tidak sesuai"),
                  const SizedBox(height: 5.0),
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      hintText: "alasan laporan",
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text("bukti gambar", style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 5.0),
                  InkWell(
                    onTap: () async {
                      File? image = await getImageFromDevice(context);
                      setState(() {
                        _imageFile = image;
                      });
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: _imageFile != null
                                ? FileImage(_imageFile!)
                                : (widget.transaction.order.reportPhoto != null
                                ? NetworkImage(widget.transaction.order.reportPhoto!)
                                : AssetImage('images/placeholder_food.png')) as ImageProvider<Object>,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (consumerOrderViewModel.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
        ],
      ),
    );
  }
}
