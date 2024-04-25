class Order {
  final int id;
  bool isVip;
  bool hasCompleted;
  int? botId;

  Order({
    required this.id,
    required this.isVip,
    this.hasCompleted = false,
  });
}
