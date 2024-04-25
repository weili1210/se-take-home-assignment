import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:food_order/widget/order_list.dart';

import 'model/bot.dart';
import 'model/order.dart';
import 'widget/action_title.dart';
import 'widget/bot_counter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Order> orders = [];
  final List<Bot> bots = [];
  Timer? assignOrderTimer;

  @override
  void initState() {
    super.initState();

    assignOrderTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      assignOrder();
    });
  }

  @override
  void dispose() {
    assignOrderTimer?.cancel();
    super.dispose();
  }

  void assignOrder() {
    final unassignedOrders = orders
        .where((order) => order.botId == null && !order.hasCompleted)
        .toList();

    if (unassignedOrders.isEmpty) return;

    final unassignedBots =
        bots.where((bot) => bot.orderProcessTimer == null).toList();

    while (unassignedOrders.isNotEmpty && unassignedBots.isNotEmpty) {
      final bot = unassignedBots.removeAt(0);
      final order = unassignedOrders.removeAt(0);

      order.botId = bot.id;

      bot.orderProcessTimer = Timer(const Duration(seconds: 10), () {
        order.hasCompleted = true;
        order.botId = null;
        bot.orderProcessTimer = null;
      });
    }

    setState(() {});
  }

  void addOrder(bool isVip) {
    orders.add(Order(id: orders.length + 1, isVip: isVip));

    orders.sort((a, b) {
      if (a.isVip && !b.isVip) return -1;
      if (!a.isVip && b.isVip) return 1;

      return a.id.compareTo(b.id);
    });

    setState(() {});
  }

  void addBot() {
    bots.add(Bot(id: bots.length + 1));
    setState(() {});
  }

  void removeBot() {
    final lastBots = bots.removeLast();
    lastBots.orderProcessTimer?.cancel();

    final order = orders.firstWhereOrNull(
      (order) => order.botId == lastBots.id,
    );

    if (order != null) {
      order.botId = null;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pendingOrders = orders.where((order) => !order.hasCompleted).toList();
    final completeOrders = orders.where((order) => order.hasCompleted).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Order'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Pending'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TabBarView(
                  children: [
                    OrderList(orders: pendingOrders),
                    OrderList(orders: completeOrders),
                  ],
                ),
              ),
              BotCounter(botsLength: bots.length),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ActionTitle(title: 'Order'),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => addOrder(false),
                          child: const Text('New Normal Order'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => addOrder(true),
                          child: const Text('New VIP Order'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const ActionTitle(title: 'Bot'),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: addBot,
                          child: const Text('+ Bot'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: removeBot,
                          child: const Text('- Bot'),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          )),
    );
  }
}
