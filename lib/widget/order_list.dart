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

    return ListView.builder(
      itemBuilder: (BuildContext _, int index) {
        final order = orders[index];

        final double bottomPadding = index == ordersLength - 1 ? 15 : 0;
        final prefixText = order.isVip ? '(VIP) ' : '';
        final postfixText = order.botId != null ? ' (Processing by bot ${order.botId})' : '';

        return Container(
          margin: EdgeInsets.only(
              top: 15, bottom: bottomPadding, left: 20, right: 20),
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
