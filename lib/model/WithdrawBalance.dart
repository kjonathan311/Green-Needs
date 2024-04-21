
class WithdrawBalance{
  final String uid;
  final String providerId;
  final String id;
  final int amount;
  final DateTime created;
  final DateTime expiration;
  final String payout_url;
  final String status;

  WithdrawBalance({
    required this.uid,
    required this.providerId,
    required this.id,
    required this.amount,
    required this.created,
    required this.expiration,
    required this.payout_url,
    required this.status,
  });
}
