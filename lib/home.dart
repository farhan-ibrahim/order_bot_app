import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:order_bot_app/models.dart';
import 'package:order_bot_app/ui/Bot.dart';
import 'package:order_bot_app/ui/controls.dart';
import 'package:order_bot_app/ui/list.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  int _orderCounter = 1;
  int _botCounter = 1;
  final List<Order> _queue = [];
  final List<Bot> _bots = [];
  final List<Order> _completedOrders = [];

  void _incrementOrderCounter() {
    setState(() {
      _orderCounter++;
    });
  }

  void _incrementBotCounter() {
    setState(() {
      _botCounter++;
    });
  }

  void _addNewOrder(OrderType type) {
    setState(() {
      final newOrder = Order(id: _orderCounter, type: type);
      _incrementOrderCounter();
      _queue.insert(
          newOrder.type == OrderType.vip ? 0 : _queue.length, newOrder);

      final availableBot = _bots.firstWhereOrNull(
        (bot) => bot.status == BotStatus.idle,
      );
      if (availableBot != null) {
        _processOrder(availableBot, newOrder);
      }
    });
  }

  void _onCompleteOrder(Order order, Bot bot) {
    setState(() {
      _completedOrders.add(order);
      if (_queue.isNotEmpty) {
        _processOrder(bot, _queue.first);
      }
    });
  }

  void _addBot() {
    setState(() {
      final newBot = Bot(id: _botCounter);
      _incrementBotCounter();
      final nextOrder = _queue
          .firstWhereOrNull((order) => order.status == OrderStatus.pending);
      if (nextOrder != null) {
        _processOrder(newBot, nextOrder);
      }
      _bots.add(newBot);
    });
  }

  void _removeBot() {
    setState(() {
      final bot = _bots.last;
      if (bot.status == BotStatus.busy) {
        final order = bot.order;
        if (order != null) {
          print("PUSHING BACK ORDER ${order.id} TO QUEUE..");
          // Update order status to pending
          // Add order back to the top of the list
          // (but behind all VIP orders)
          order.updateStatus(OrderStatus.pending);

          final lastVIPOrder = _queue.lastWhereOrNull(
            (order) => order.type == OrderType.vip,
          );
          final int idx = _queue.indexOf(lastVIPOrder ?? _queue.first);
          _queue.insert(idx, order);
        }
      }
      _bots.removeLast();
    });
  }

  void _processOrder(Bot bot, Order order) {
    order.updateStatus(OrderStatus.inProgress);
    bot.addOrder(order);

    print("ASSIGNED ORDER ${bot.order} TO BOT ${bot.id}...");

    setState(() {
      _queue.remove(order);
      final idx = _bots.indexWhere((b) => b.id == bot.id);
      if (idx != -1) {
        _bots[idx] = bot;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Order Management System"),
        ),
        body: Center(
          child: Row(
            children: [
              ListWidget(
                list: _queue,
                title: "PENDING ORDERS",
              ),
              ListWidget(
                list: _bots,
                title: "IN PROGRESS",
                itemBuilder: (Bot bot) {
                  return BotWidget(
                    id: bot.id,
                    order: bot.order,
                    onCompleteOrder: (order) => _onCompleteOrder(order, bot),
                  );
                },
              ),
              ListWidget(
                list: _completedOrders,
                title: "COMPLETED ORDERS",
              ),
            ],
          ),
        ),
        floatingActionButton: Controls(
          addNormalOrderCtrl: () {
            _addNewOrder(OrderType.normal);
          },
          addVipOrderCtrl: () {
            _addNewOrder(OrderType.vip);
          },
          addBotCtrl: () {
            _addBot();
          },
          removeBotCtrl: () {
            _removeBot();
          },
        ));
  }
}
