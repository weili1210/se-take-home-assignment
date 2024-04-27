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

  void addOrder(bool isVip) {
    final order = Order(
        id: pendingOrders.length + completeOrders.length + 1, isVip: isVip);

    final index = isVip ? vipOrderCount++ : pendingOrders.length;
    pendingOrders.insert(index, order);

    checkPendingOrder();

    setState(() {});
  }

  void addBot() {
    final bot = Bot(id: bots.length + 1);

    bots.add(bot);

    checkPendingOrder();

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

    // handle situation where the last bot is processing an order and all other bot when idle
    // when the last bot is removed other bot wouldn't jump on to the order automatically
    checkPendingOrder();

    setState(() {});
  }

  void assignOrder(Order order, Bot bot) {
    order.botId = bot.id;

    bot.orderProcessTimer = Timer(const Duration(seconds: 10), () {
      pendingOrders.removeWhere((pendingOrder) => pendingOrder.id == order.id);
      completeOrders.add(order);

      order.hasCompleted = true;
      bot.orderProcessTimer = null;

      if (order.isVip) {
        vipOrderCount--;
      }

      setState(() {});

      checkPendingOrder();
    });
  }

  void checkPendingOrder() {
    if (pendingOrders.isEmpty || bots.isEmpty) return;

    final unassignedOrder =
        pendingOrders.firstWhereOrNull((order) => order.botId == null);
    final unassignedBot =
        bots.firstWhereOrNull((bot) => bot.orderProcessTimer == null);

    if (unassignedOrder == null || unassignedBot == null) return;

    assignOrder(unassignedOrder, unassignedBot);
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
            ],
          )),
    );
  }
}
