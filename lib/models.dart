import 'dart:async';

enum OrderStatus {
  pending('PENDING'),
  inProgress('IN PROGRESS'),
  completed('COMPLETED'),
  cancelled('CANCELLED');

  const OrderStatus(this.value);
  final String value;
}

enum OrderType {
  normal("NORMAL"),
  vip("VIP");

  const OrderType(this.value);
  final String value;
}

class Order {
  final int id;
  final OrderType type;
  OrderStatus status;

  Order({
    required this.id,
    this.status = OrderStatus.pending,
    this.type = OrderType.normal,
  });

  Order updateStatus(OrderStatus status) {
    this.status = status;
    return this;
  }

  @override
  String toString() {
    return '[${type.value}] Order $id | ${status.value}';
  }
}

enum BotStatus {
  idle('IDLE'),
  busy('BUSY');

  const BotStatus(this.value);
  final String value;
}

class Bot {
  final int id;
  BotStatus status;
  Order? order;
  late Timer timer;

  Bot({
    required this.id,
    this.status = BotStatus.idle,
  });

  void addOrder(Order newOrder) {
    order = newOrder;
    status = BotStatus.busy;
    timer = Timer(const Duration(seconds: 5), () {
      completeOrder(newOrder);
    });
  }

  void completeOrder(Order inProgressOrder) {
    inProgressOrder.updateStatus(OrderStatus.completed);
    order = null;
    status = BotStatus.idle;
  }
}
