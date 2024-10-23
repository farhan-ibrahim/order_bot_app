import 'dart:async';

import 'package:flutter/material.dart';
import 'package:order_bot_app/models.dart';

// ignore: must_be_immutable
class BotWidget extends StatefulWidget {
  final int id;
  BotStatus status;
  Order? order;
  void Function(Order) onCompleteOrder;

  BotWidget({
    super.key,
    required this.id,
    required this.order,
    required this.onCompleteOrder,
    this.status = BotStatus.idle,
  });

  @override
  State<BotWidget> createState() => _BotWidgetState();
}

class _BotWidgetState extends State<BotWidget> {
  late Timer _timer;
  Order? _order;
  BotStatus _status = BotStatus.idle;

  @override
  void initState() {
    super.initState();
    start(widget.order!);
  }

  @override
  void didUpdateWidget(BotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.order != null && widget.order != oldWidget.order) {
      print("TAKING NEW ORDER ${widget.order}");
      start(widget.order!);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void start(Order newOrder) {
    if (_order != null) {
      return;
    }
    setState(() {
      _order = newOrder;
      _status = BotStatus.busy;
      _timer = Timer(const Duration(seconds: 5), () {
        end(newOrder);
      });
    });
  }

  void end(Order inProgressOrder) {
    setState(() {
      inProgressOrder.updateStatus(OrderStatus.completed);
      _order = null;
      _status = BotStatus.idle;
    });
    _timer.cancel();
    widget.onCompleteOrder(inProgressOrder);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("BOT ${widget.id}"),
      subtitle: _order != null ? Text("ORDER: ${_order?.toString()}") : null,
      trailing: Text(_status.value),
    );
  }
}
