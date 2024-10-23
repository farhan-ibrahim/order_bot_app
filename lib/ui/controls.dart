import 'package:flutter/material.dart';

class Controls extends StatelessWidget {
  final void Function() addNormalOrderCtrl;
  final void Function() addVipOrderCtrl;
  final void Function() addBotCtrl;
  final void Function() removeBotCtrl;

  const Controls({
    super.key,
    required this.addNormalOrderCtrl,
    required this.addVipOrderCtrl,
    required this.addBotCtrl,
    required this.removeBotCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          color: Theme.of(context).colorScheme.inversePrimary,
          padding: const EdgeInsets.all(8),
          child: const Text(
            "ADD ORDER",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: addNormalOrderCtrl,
              tooltip: 'Add Normal Order',
              child: const Icon(Icons.add),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              onPressed: addVipOrderCtrl,
              tooltip: 'Add VIP Order',
              child: const Text(
                "VIP",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          color: Theme.of(context).colorScheme.inversePrimary,
          padding: const EdgeInsets.all(8),
          child: const Text(
            "BOT",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: addBotCtrl,
              tooltip: 'Add Bot',
              child: const Icon(Icons.add),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              onPressed: removeBotCtrl,
              tooltip: 'Remove Bot',
              child: const Icon(Icons.remove),
            ),
          ],
        ),
      ],
    );
  }
}
