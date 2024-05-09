import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenneeds/model/OrderItem.dart';
import 'package:greenneeds/model/UserChat.dart';
import 'package:greenneeds/ui/chat/chat_screen.dart';
import 'package:greenneeds/ui/consumer/order/report_order_page.dart';
import 'package:greenneeds/ui/utils.dart';
import 'package:provider/provider.dart';
import '../../../model/Address.dart';
import '../../../model/MenuItem.dart';
import '../../../model/Rating.dart';
import 'consumer_order_view_model.dart';

class ConsumerOrderDetailPage extends StatefulWidget {
  final OrderItemWithProviderAndConsumer transaction;

  const ConsumerOrderDetailPage({super.key, required this.transaction});

  @override
  State<ConsumerOrderDetailPage> createState() =>
      _ConsumerOrderDetailPageState();
}

class _ConsumerOrderDetailPageState extends State<ConsumerOrderDetailPage> {
  @override
  Widget build(BuildContext context) {
    final consumerOrderViewModel = Provider.of<ConsumerOrderViewModel>(context);
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
            IconButton(
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChatScreen(
                              user: UserChat(
                            uid: widget.transaction.provider.uid,
                            name: widget.transaction.provider.name,
                            email: widget.transaction.provider.email,
                            photoUrl: widget.transaction.provider.photoUrl,
                            transactionId: widget.transaction.order.uid,
                            type: 'provider',
                          ))));
                },
                icon: Icon(Icons.chat)),
            StreamBuilder(
              stream: consumerOrderViewModel
                  .getStatus(widget.transaction.order.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                } else {
                  if (snapshot.hasData && snapshot.data != null) {
                    String status = snapshot.data!;
                    if (status == "order selesai") {
                      return FutureBuilder<Rating?>(
                        future: consumerOrderViewModel
                            .getRating(widget.transaction),
                        builder: (context, ratingSnapshot) {
                          if (ratingSnapshot.hasError) {
                            return Text("${ratingSnapshot.error}");
                          } else {
                            final rating = ratingSnapshot.data;
                            if (rating != null) {
                              return Row(
                                children: [
                                  IconButton(
                                      onPressed: () async {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(builder: (context) =>
                                                ReportOrderPage(transaction: widget.transaction)
                                            )
                                        );
                                      },
                                      icon: Icon(Icons.report_problem)),
                                  IconButton(
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
                                  ),
                                ],
                              );
                            } else {
                              return Row(
                                children: [
                                  IconButton(
                                      onPressed: () async {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(builder: (context) =>
                                                ReportOrderPage(transaction: widget.transaction)
                                        )
                                        );
                                      },
                                      icon: Icon(Icons.report_problem)),
                                  IconButton(
                                    onPressed: () async {
                                      await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return RatingDialog(
                                            onSubmit:
                                                (int rating, String comment) {
                                              consumerOrderViewModel.addRating(
                                                  widget.transaction,
                                                  rating,
                                                  comment);
                                            },
                                          );
                                        },
                                      );
                                    },
                                    icon: Icon(Icons.rate_review),
                                  ),
                                ],
                              );
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
                            stream: consumerOrderViewModel
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
                                  return Container(); // Placeholder or empty widget
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
                              "Detail Penyedia Makanan ",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(widget.transaction.provider.name),
                            Text(widget.transaction.provider.phoneNumber),
                            Text(
                                "${widget.transaction.provider.address}, ${widget.transaction.provider.postalcode}, ${widget.transaction.provider.city}"),
                          ]),
                    ),
                    if (widget.transaction.order.type == "kurir")
                      FutureBuilder<Address?>(
                        future: consumerOrderViewModel.getAddress(
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
                      future: consumerOrderViewModel.getAlaCarteItems(
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
                      future: consumerOrderViewModel.getPaketItems(
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
              stream: consumerOrderViewModel
                  .getStatus(widget.transaction.order.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final status = snapshot.data;
                  if (status == "sedang dikirim" ||
                      status == "order bisa diambil") {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: ElevatedButton(
                        onPressed: () async {
                          await consumerOrderViewModel.changeStatusOrder(
                              widget.transaction, "order selesai");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: Text(
                          "order sudah diterima",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  } else if (status == "sedang diproses") {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: ElevatedButton(
                        onPressed: () async {
                          await consumerOrderViewModel
                              .cancelOrder(widget.transaction);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text(
                          "order dibatalkan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
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

class RatingDialog extends StatefulWidget {
  final Function(int, String) onSubmit;

  const RatingDialog({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _rating = 0;
  TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Rate order ini"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                  size: 30.0,
                ),
                onPressed: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
              );
            }),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            widget.onSubmit(_rating, _commentController.text);
            Navigator.of(context).pop();
          },
          child: Text('Submit'),
        ),
      ],
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
                size: 30.0,
              );
            }),
          ),
          SizedBox(height: 20),
          if (comment != null)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child:
                  Text(comment, maxLines: 3, overflow: TextOverflow.ellipsis),
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
