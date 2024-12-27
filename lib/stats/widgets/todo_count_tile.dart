import 'package:flutter/material.dart';

class TodoCountTile extends StatelessWidget {
  const TodoCountTile({
    required this.count,
    required this.labelText,
    required this.icon,
    this.iconColor,
    this.padding,
    super.key,
  });

  final int count;
  final String labelText;
  final IconData icon;
  final Color? iconColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: padding ?? const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: iconColor ?? Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                labelText,
                style: textTheme.headlineSmall,
              ),
            ],
          ),
          Text(
            count.toString(),
            style: textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}
