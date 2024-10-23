import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:order_bot_app/models.dart';
import 'package:order_bot_app/ui/Bot.dart';
import 'package:order_bot_app/ui/controls.dart';

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

  void _addOrderToBot(Bot bot, Order order) {
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

  void _addOrder(OrderType type) {
    setState(() {
      final newOrder = Order(id: _orderCounter, type: type);
      _incrementOrderCounter();
      if (newOrder.type == OrderType.vip) {
        _queue.insert(0, newOrder);
      } else {
        _queue.add(newOrder);
      }
      final availableBot = _bots.firstWhereOrNull(
        (bot) => bot.status == BotStatus.idle,
      );
      if (availableBot != null) {
        _addOrderToBot(availableBot, newOrder);
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
        _addOrderToBot(newBot, nextOrder);
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
          // Add order back to the list behind all VIP orders
          order.updateStatus(OrderStatus.pending);
          _queue.insert(
              _queue.indexWhere((o) => o.type == OrderType.vip), order);
        }
      }
      _bots.removeLast();
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
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                width: MediaQuery.of(context).size.width / 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "PENDING ORDERS",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _queue.length,
                        itemBuilder: (context, index) {
                          final order = _queue[index];
                          return ListTile(
                            dense: true,
                            title: Text(order.toString()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                width: MediaQuery.of(context).size.width / 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "IN PROGRESS",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _bots.length,
                        itemBuilder: (context, index) {
                          final bot = _bots[index];
                          print("BOT.. ${bot.status}");
                          print("BOT ORDER.. ${bot.order}");
                          return BotWidget(
                            id: bot.id,
                            order: bot.order,
                            onCompleteOrder: (order) {
                              setState(() {
                                _completedOrders.add(order);
                                if (_queue.isNotEmpty) {
                                  _addOrderToBot(bot, _queue.first);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                width: MediaQuery.of(context).size.width / 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "COMPLETED ORDERS",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _completedOrders.length,
                        itemBuilder: (context, index) {
                          final order = _completedOrders[index];
                          return ListTile(
                            dense: true,
                            title: Text(order.toString()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Controls(
          addNormalOrderCtrl: () {
            _addOrder(OrderType.normal);
          },
          addVipOrderCtrl: () {
            _addOrder(OrderType.vip);
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
