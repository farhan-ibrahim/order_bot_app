// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:order_bot_app/main.dart';
import 'package:order_bot_app/models.dart';

void main() {
  group("Orders", () {
    final normalOrderOne = Order(id: 1, type: OrderType.normal);
    final normalOrderTwo = Order(id: 2, type: OrderType.normal);
    final vipOrderOne = Order(id: 3, type: OrderType.vip);

    testWidgets('Add new normal order', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify that column is empty.
      expect(find.text('PENDING ORDERS'), findsOneWidget);
      expect(find.text('IN PROGRESS'), findsOneWidget);
      expect(find.text('COMPLETED ORDERS'), findsOneWidget);

      expect(find.text(normalOrderOne.toString()), findsNothing);

      // Add orders.
      await tester.tap(find.byKey(const Key('add_normal_order')));
      await tester.pump();
      expect(find.text(normalOrderOne.toString()), findsOneWidget);

      await tester.tap(find.byKey(const Key('add_normal_order')));
      await tester.pump();
      expect(find.text(normalOrderTwo.toString()), findsOneWidget);

      // Verify that new order is added.
      final orders =
          tester.widgetList<ListTile>(find.byType(ListTile)).toList();
      expect(orders.length, 2);
      expect((orders.first.title as Text).data, normalOrderOne.toString());
      expect((orders.last.title as Text).data, normalOrderTwo.toString());
    });
    testWidgets('Add new VIP order', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that column is empty.
      expect(find.text('PENDING ORDERS'), findsOneWidget);
      expect(find.text('IN PROGRESS'), findsOneWidget);
      expect(find.text('COMPLETED ORDERS'), findsOneWidget);

      expect(find.text(normalOrderOne.toString()), findsNothing);

      // Add orders.
      await tester.tap(find.byKey(const Key('add_normal_order')));
      await tester.pump();
      expect(find.text(normalOrderOne.toString()), findsOneWidget);

      await tester.tap(find.byKey(const Key('add_normal_order')));
      await tester.pump();
      expect(find.text(normalOrderTwo.toString()), findsOneWidget);

      await tester.tap(find.byKey(const Key('add_vip_order')));
      await tester.pump();
      expect(find.text(vipOrderOne.toString()), findsOneWidget);

      // Verify that new order is added.
      final orders =
          tester.widgetList<ListTile>(find.byType(ListTile)).toList();
      expect(orders.length, 3);
      expect((orders.first.title as Text).data, vipOrderOne.toString());
      expect((orders[1].title as Text).data, normalOrderOne.toString());
      expect((orders.last.title as Text).data, normalOrderTwo.toString());
    });
  });

  group("Bots", () {
    testWidgets('Add new bot', (WidgetTester widget) async {
      await widget.pumpWidget(const MyApp());

      // Verify that column is empty.
      expect(find.text('PENDING ORDERS'), findsOneWidget);
      expect(find.text('IN PROGRESS'), findsOneWidget);
      expect(find.text('COMPLETED ORDERS'), findsOneWidget);

      // Add bots.
      await widget.tap(find.byKey(const Key('add_bot')));
      await widget.pump();

      await widget.tap(find.byKey(const Key('add_bot')));
      await widget.pump();

      // Verify that new bot is added.
      final bots = widget.widgetList<ListTile>(find.byType(ListTile)).toList();
      expect(bots.length, 2);
      expect((bots.first.title as Text).data, 'BOT 1');
      expect((bots.last.title as Text).data, 'BOT 2');

      expect((bots.first.trailing as Text).data, 'IDLE');
      expect((bots.last.trailing as Text).data, 'IDLE');
    });

    testWidgets('Assign order to bot', (WidgetTester widget) async {
      var tiles = <ListTile>[];
      await widget.pumpWidget(const MyApp());

      // Verify that column is empty.
      expect(find.text('PENDING ORDERS'), findsOneWidget);
      expect(find.text('IN PROGRESS'), findsOneWidget);
      expect(find.text('COMPLETED ORDERS'), findsOneWidget);

      // Add bots.
      await widget.tap(find.byKey(const Key('add_bot')));
      await widget.pump();

      // Verify that new bot is added.
      tiles = widget.widgetList<ListTile>(find.byType(ListTile)).toList();
      expect(tiles.length, 1);
      expect((tiles.first.title as Text).data, 'BOT 1');

      // Add new order.
      await widget.tap(find.byKey(const Key('add_normal_order')));
      await widget.pump();

      final normalOrderOne = Order(id: 1, type: OrderType.normal);

      // Order is immediately assigned to bot.
      expect(find.text(normalOrderOne.toString()), findsNothing);

      tiles = widget.widgetList<ListTile>(find.byType(ListTile)).toList();
      expect(tiles.length, 1);
      expect((tiles.first.trailing as Text).data, 'BUSY');
      expect((tiles.first.subtitle as Text).data,
          'ORDER: [NORMAL] Order 1 | IN PROGRESS');

      // Wait for timer to complete.
      await widget.pumpAndSettle(const Duration(seconds: 10));
      tiles = widget.widgetList<ListTile>(find.byType(ListTile)).toList();
      expect(tiles.length, 2);
      // First tile is idle bot
      expect((tiles.first.title as Text).data, 'BOT 1');
      expect((tiles.first.trailing as Text).data, 'IDLE');

      // Second tile is completed order.
      expect((tiles.last.title as Text).data, '[NORMAL] Order 1 | COMPLETED');
    });
    testWidgets('Taking new order', (WidgetTester widget) async {
      var tiles = <ListTile>[];
      await widget.pumpWidget(const MyApp());

      // Verify that column is empty.
      expect(find.text('PENDING ORDERS'), findsOneWidget);
      expect(find.text('IN PROGRESS'), findsOneWidget);
      expect(find.text('COMPLETED ORDERS'), findsOneWidget);

      // Add orders.
      await widget.tap(find.byKey(const Key('add_normal_order')));
      await widget.pump();

      await widget.tap(find.byKey(const Key('add_normal_order')));
      await widget.pump();

      await widget.tap(find.byKey(const Key('add_vip_order')));
      await widget.pump();

      // Verify that new orders is added.
      tiles = widget.widgetList<ListTile>(find.byType(ListTile)).toList();
      expect(tiles.length, 3);
      expect((tiles.first.title as Text).data, '[VIP] Order 3 | PENDING');
      expect((tiles[1].title as Text).data, '[NORMAL] Order 1 | PENDING');
      expect((tiles.last.title as Text).data, '[NORMAL] Order 2 | PENDING');

      // Add bots.
      await widget.tap(find.byKey(const Key('add_bot')));
      await widget.pump();

      // Order is immediately assigned to bot.
      expect(find.text('[VIP] Order 3 | PENDING'), findsNothing);
      tiles = widget.widgetList<ListTile>(find.byType(ListTile)).toList();
      expect(tiles.length, 3);
      // First tile is pending normal order
      expect((tiles.first.title as Text).data, '[NORMAL] Order 1 | PENDING');
      // Second tile is pending normal order
      expect((tiles[1].title as Text).data, '[NORMAL] Order 2 | PENDING');
      // Third tile is busy bot
      expect((tiles.last.subtitle as Text).data,
          'ORDER: [VIP] Order 3 | IN PROGRESS');

      // Wait for timer to complete.
      await widget.pumpAndSettle(const Duration(seconds: 11));
      tiles = widget.widgetList<ListTile>(find.byType(ListTile)).toList();
      expect(tiles.length, 3);
      // First tile is pending normal order
      expect((tiles.first.title as Text).data, '[NORMAL] Order 2 | PENDING');
      // Second tile is busy bot
      expect((tiles[1].subtitle as Text).data,
          'ORDER: [NORMAL] Order 1 | IN PROGRESS');
      // Third tile is completed VIP order
      expect((tiles.last.title as Text).data, '[VIP] Order 3 | COMPLETED');

      // Add new bot.
      await widget.tap(find.byKey(const Key('add_bot')));
      await widget.pump();

      // Pending Order is immediately assigned to bot.
      tiles = widget.widgetList<ListTile>(find.byType(ListTile)).toList();
      expect(tiles.length, 3);
      // First tile is busy bot
      expect((tiles.first.subtitle as Text).data,
          'ORDER: [NORMAL] Order 1 | IN PROGRESS');
      // Second tile is busy new bot
      expect((tiles[1].title as Text).data, 'BOT 2');
      expect((tiles[1].subtitle as Text).data,
          'ORDER: [NORMAL] Order 2 | IN PROGRESS');
      // Third tile is completed VIP order
      expect((tiles.last.title as Text).data, '[VIP] Order 3 | COMPLETED');

      // Wait for timer to complete.
      await widget.pumpAndSettle(const Duration(seconds: 10));
    });
  });
}
