

import 'package:flutter/material.dart';
import 'package:greenneeds/ui/admin/user_report/report_view_model.dart';
import 'package:provider/provider.dart';
import '../../../model/Address.dart';
import '../../../model/MenuItem.dart';
import '../../../model/OrderItem.dart';
import '../../utils.dart';

class ReportDetailPage extends StatefulWidget {
  final OrderItemWithProviderAndConsumer transaction;

  const ReportDetailPage({super.key, required this.transaction});

  @override
  State<ReportDetailPage> createState() =>
      _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  @override
  Widget build(BuildContext context) {
    final reportViewModel = Provider.of<ReportViewModel>(context);
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text("Detail Order"),
          actions: [

          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      color: Colors.black12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Order ID", style: TextStyle(fontSize: 16)),
                          Text("${widget.transaction.order.uid}")
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Status:"),
                          StreamBuilder(
                            stream: reportViewModel
                                .getStatus(widget.transaction.order.uid),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text("${snapshot.error}");
                              } else {
                                if (snapshot.hasData && snapshot.data != null) {
                                  String status = snapshot.data!;
                                  Color textColor = statusColor(status);
                                  return Text(snapshot.data!,
                                      style: TextStyle(color: textColor));
                                } else {
                                  return Container();
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 10, color: Colors.black12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Tipe Order:"),
                          Text("${widget.transaction.order.type}")
                        ],
                      ),
                    ),
                    const Divider(thickness: 10, color: Colors.black12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Alasan Laporan:"),
                        Text("${widget.transaction.order.reportReason}",style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text("Bukti Gambar"),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: (widget.transaction.order.reportPhoto != null
                                    ? NetworkImage(widget.transaction.order.reportPhoto!)
                                    : AssetImage('images/placeholder_food.png')) as ImageProvider<Object>,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ),

                    const Divider(thickness: 10, color: Colors.black12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Detail Penyedia makanan",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(widget.transaction.provider.name),
                            Text(widget.transaction.provider.email),
                            Text(widget.transaction.provider.phoneNumber),
                          ]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Detail Pembeli",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(widget.transaction.consumer.name),
                            Text(widget.transaction.consumer.email),
                            Text(widget.transaction.consumer.phoneNumber),
                          ]),
                    ),
                    if (widget.transaction.order.type == "kurir")
                      FutureBuilder<Address?>(
                        future: reportViewModel.getAddress(
                            widget.transaction.consumer.uid,
                            widget.transaction.order.addressDestinationId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: const CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            // Use the fetched address details
                            final address = snapshot.data?.address ??
                                'Alamat tidak tersedia';
                            final postalcode = snapshot.data?.postalcode ??
                                'Kode pos tidak tersedia';
                            final city =
                                snapshot.data?.city ?? 'Kota tidak tersedia';
                            final note =
                                widget.transaction.order.consumerNote ?? '';

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    "Alamat Pengiriman",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text("$address, $postalcode, $city"),
                                  if (note.isNotEmpty)
                                    Text("catatan: $note",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    const Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Divider(thickness: 10, color: Colors.black12),
                    ),
                    const Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 5),
                      child: const Text(
                        "Rangkuman Order :",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    FutureBuilder<List<Product>?>(
                      future: reportViewModel.getAlaCarteItems(
                          widget.transaction.order.providerId,
                          widget.transaction.order.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                              width: 300,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ));
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        } else if (snapshot.hasData) {
                          List<Product> data = snapshot.data ?? [];
                          if (data.isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    final product = snapshot.data![index];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  "${product.quantity}x ${product.menuItem.name}"),
                                              Text(
                                                  "${formatCurrency(product.menuItem.discountedPrice * product.quantity)}")
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          } else {
                            return Container();
                          }
                        } else {
                          return Container();
                        }
                      },
                    ),
                    FutureBuilder<List<Paket>?>(
                      future: reportViewModel.getPaketItems(
                          widget.transaction.order.providerId,
                          widget.transaction.order.uid),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        } else if (snapshot.hasData) {
                          List<Paket> data = snapshot.data ?? [];
                          if (data.isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    final paket = snapshot.data![index];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  "${paket.quantity}x ${paket.name}"),
                                              Text(
                                                  "${formatCurrency(paket.discountedPrice * paket.quantity)}")
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 30),
                                            child: ListView.builder(
                                              itemCount: paket.products.length,
                                              physics:
                                              NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemBuilder:
                                                  (BuildContext context,
                                                  int index) {
                                                return Text(
                                                    "${paket.products[index].quantity}x ${paket.products[index].menuItem.name}");
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          } else {
                            return Container();
                          }
                        } else {
                          return Container();
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Divider(thickness: 10, color: Colors.black12),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Subtotal:"),
                              Text(formatCurrency(
                                  widget.transaction.order.totalPrice)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Biaya Admin:"),
                              Text(formatCurrency(
                                  widget.transaction.order.adminFee))
                            ],
                          ),
                          if (widget.transaction.order.type == "kurir")
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Ongkos Kirim:"),
                                Text(formatCurrency(
                                    widget.transaction.order.shippingFee!))
                              ],
                            ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total :",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                  formatCurrency(
                                      widget.transaction.order.totalPayment),
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
