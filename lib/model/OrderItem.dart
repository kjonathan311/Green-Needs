
import 'Profile.dart';

class OrderItem {
  final String uid;
  final String addressDestinationId;
  final String consumerId;
  final String providerId;
  final DateTime date;
  final int totalPrice;
  final int adminFee;
  final int? shippingFee;
  final int totalPayment;
  final String status;
  final String type;
  final String? consumerNote;
  final int? rating;

  OrderItem({
    required this.uid,
    required this.addressDestinationId,
    required this.consumerId,
    required this.providerId,
    required this.date,
    required this.totalPrice,
    required this.adminFee,
    this.shippingFee,
    required this.status,
    required this.type,
    this.consumerNote,
    this.rating,
  }) : totalPayment = type == "kurir" ? totalPrice + adminFee + (shippingFee ?? 0) : totalPrice + adminFee;
}

class OrderItemWithProviderAndConsumer {
  final OrderItem order;
  final FoodProviderProfile provider;
  final ConsumerProfile consumer;
  final int itemCount;

  OrderItemWithProviderAndConsumer({required this.order, required this.provider,required this.consumer,required this.itemCount});
}
