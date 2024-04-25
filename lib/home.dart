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
  int vipOrderCount = 0;
  final List<Order> pendingOrders = [];
  final List<Order> completeOrders = [];
  final List<Bot> bots = [];
  Timer? assignOrderTimer;

  @override
  void initState() {
    super.initState();

    assignOrderTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      assignOrder();
    });
  }

  @override
  void dispose() {
    assignOrderTimer?.cancel();
    super.dispose();
  }

  void assignOrder() {
    final unassignedOrders =
        pendingOrders.where((order) => order.botId == null).toList();

    if (unassignedOrders.isEmpty) return;

    final unassignedBots =
        bots.where((bot) => bot.orderProcessTimer == null).toList();

    if (unassignedBots.isEmpty) return;

    while (unassignedOrders.isNotEmpty && unassignedBots.isNotEmpty) {
      final bot = unassignedBots.removeAt(0);
      final order = unassignedOrders.removeAt(0);

      order.botId = bot.id;

      bot.orderProcessTimer =
          Timer(const Duration(seconds: 10), () => completeOrder(order, bot));
    }

    setState(() {});
  }

  void completeOrder(Order order, Bot bot) {
    pendingOrders.removeWhere((pendingOrder) => pendingOrder.id == order.id);
    completeOrders.add(order);

    order.hasCompleted = true;
    bot.orderProcessTimer = null;

    if (order.isVip) {
      vipOrderCount--;
    }

    setState(() {});
  }

  void addOrder(bool isVip) {
    final order = Order(id: pendingOrders.length + 1, isVip: isVip);

    final index = isVip ? vipOrderCount++ : pendingOrders.length;
    pendingOrders.insert(index, order);

    setState(() {});
  }

  void addBot() {
    final bot = Bot(id: bots.length + 1);

    bots.add(bot);

    setState(() {});
  }

  void removeBot() {
    final lastBots = bots.removeLast();
    lastBots.orderProcessTimer?.cancel();

    final order = pendingOrders.firstWhereOrNull(
      (order) => order.botId == lastBots.id,
    );

    if (order != null) {
      order.botId = null;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
