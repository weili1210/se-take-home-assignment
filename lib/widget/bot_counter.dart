import 'package:flutter/material.dart';

class BotCounter extends StatelessWidget {
  const BotCounter({
    super.key,
    required this.botsLength,
  });

  final int botsLength;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.greenAccent,
      ),
      child: Text('Bot count: $botsLength'),
    );
  }
}