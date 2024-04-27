import 'package:flutter/material.dart';

import '../model/order.dart';

class OrderList extends StatelessWidget {
  const OrderList({
    super.key,
    required this.orders,
  });

  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    final ordersLength = orders.length;

    if (ordersLength == 0) {
      return const Center(
        child: Text('No Orders'),
      );
    }

    return ListView.builder(
      itemBuilder: (BuildContext _, int index) {
        final order = orders[index];

        final double bottomPadding = index == ordersLength - 1 ? 15 : 0;
        final prefixText = order.isVip ? '(VIP) ' : '';
        final processText = order.hasCompleted ? 'Completed' : 'Processing';
        final postfixText =
            order.botId != null ? ' ($processText by bot ${order.botId})' : '';

        return Container(
          margin: EdgeInsets.only(
            bottom: bottomPadding,
            top: 15,
            left: 20,
            right: 20,
          ),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.deepPurpleAccent.withOpacity(0.3),
          ),
          child: Text('${prefixText}Order ${order.id}$postfixText'),
        );
      },
      itemCount: ordersLength,
    );
  }
}
