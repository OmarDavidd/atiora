import 'package:flutter/material.dart';

class CustomStateWidget extends StatelessWidget {
  final Color color;
  final String text;
  final VoidCallback? onTap;
  final bool showChevron;

  const CustomStateWidget({
    super.key,
    required this.color,
    required this.text,
    this.onTap,
    this.showChevron = true,
  });

  bool get _isInteractive => onTap != null;
  bool get _shouldShowChevron => showChevron && _isInteractive;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(25);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: borderRadius,
            border: Border.all(color: color, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              if (_shouldShowChevron) ...[
                const SizedBox(width: 6),
                Icon(Icons.keyboard_arrow_down, size: 16, color: color),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
