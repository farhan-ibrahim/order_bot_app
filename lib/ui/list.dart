import 'package:flutter/material.dart';

class ListWidget<T> extends StatelessWidget {
  final List<T> list;
  final String title;
  final Widget Function(T)? itemBuilder;

  const ListWidget({
    super.key,
    required this.list,
    required this.title,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              key: Key("${title}_list"),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return itemBuilder != null
                    ? itemBuilder!(item)
                    : ListTile(
                        title: Text(item.toString()),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
