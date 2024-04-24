import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:greenneeds/model/OrderItem.dart';
import 'package:greenneeds/ui/provider/order/provider_order_view_model.dart';
import 'package:greenneeds/ui/utils.dart';
import 'package:provider/provider.dart';
import '../../../model/Address.dart';
import '../../../model/MenuItem.dart';
import '../../../model/Rating.dart';
import '../../../model/UserChat.dart';
import '../../chat/chat_screen.dart';

class ProviderOrderDetailPage extends StatefulWidget {
  final OrderItemWithProviderAndConsumer transaction;

  const ProviderOrderDetailPage({super.key, required this.transaction});

  @override
  State<ProviderOrderDetailPage> createState() =>
      _ProviderOrderDetailPageState();
}

class _ProviderOrderDetailPageState extends State<ProviderOrderDetailPage> {
  @override
  Widget build(BuildContext context) {
    final providerOrderViewModel = Provider.of<ProviderOrderViewModel>(context);
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
            IconButton(onPressed: ()async{
              await Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) =>
                          ChatScreen(user:UserChat(
                            uid: widget.transaction.consumer.uid,
                            name: widget.transaction.consumer.name,
                            email: widget.transaction.consumer.email,
                            photoUrl: widget.transaction.consumer.photoUrl,
                            transactionId: widget.transaction.order.uid,
                            type: 'consumer',
                          ))));
            }, icon: Icon(Icons.chat)),

            StreamBuilder(
              stream: providerOrderViewModel.getStatus(widget.transaction.order.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                } else {
                  if (snapshot.hasData && snapshot.data != null) {
                    String status = snapshot.data!;
                    if (status == "order selesai") {
                      return FutureBuilder<Rating?>(
                        future: providerOrderViewModel.getRating(widget.transaction),
                        builder: (context, ratingSnapshot) {
                          if (ratingSnapshot.hasError) {
                            return Text("${ratingSnapshot.error}");
                          } else {
                            final rating = ratingSnapshot.data;
                            if (rating != null) {
                              return IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ViewRatingDialog(
                                        rating: rating.rating,
                                        comment: rating.comment,
                                      );
                                    },
                                  );
                                },
                                icon: Icon(Icons.rate_review),
                              );
                            }else{
                              return Container();
                            }
                          }
                        },
                      );
                    } else {
                      return Container();
                    }
                  } else {
                    return Container();
                  }
                }
              },
            ),

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
                            stream: providerOrderViewModel
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
                        future: providerOrderViewModel.getAddress(
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
                      future: providerOrderViewModel.getAlaCarteItems(
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
                      future: providerOrderViewModel.getPaketItems(
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
            StreamBuilder<String?>(
              stream: providerOrderViewModel.getStatus(widget.transaction.order.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final status = snapshot.data;
                  if (status == "sedang diproses") {
                    return ConfirmOrderWidget(transaction: widget.transaction);
                  }
                  if(status == "telah dikonfirmasi"){
                    return DeliverOrderWidget(transaction: widget.transaction);
                  } else {
                    return SizedBox();
                  }
                }
              },
            )

          ],
        ));
  }
}

class ConfirmOrderWidget extends StatelessWidget {
  final OrderItemWithProviderAndConsumer transaction;
  const ConfirmOrderWidget({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final providerOrderViewModel = Provider.of<ProviderOrderViewModel>(context);
    return  Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await providerOrderViewModel.confirmOrder(transaction, false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  "Batal",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await providerOrderViewModel.confirmOrder(transaction, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  "Konfirmasi",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}

class DeliverOrderWidget extends StatelessWidget {
  final OrderItemWithProviderAndConsumer transaction;
  const DeliverOrderWidget({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final providerOrderViewModel = Provider.of<ProviderOrderViewModel>(context);
    String newStatus = transaction.order.type == "kurir" ? "sedang dikirim" : "order bisa diambil";
    String newStatusButton = transaction.order.type == "kurir" ? "update order:   sedang dikirim" : "update order:   order bisa diambil";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: ElevatedButton(
        onPressed: () async {
          await providerOrderViewModel.changeStatusOrder(transaction, newStatus);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
        ),
        child: Text(
          "${newStatusButton}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class ViewRatingDialog extends StatelessWidget {
  final int rating;
  final String comment;

  const ViewRatingDialog({
    Key? key,
    required this.rating,
    required this.comment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Rating Detail"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.orange,
                size: 40.0,
              );
            }),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(comment,maxLines: 3,overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }
}
