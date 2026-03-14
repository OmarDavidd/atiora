import 'package:flutter/material.dart';

class AddBookFormSection extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry? contentPadding;

  const AddBookFormSection({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final padding = contentPadding ?? EdgeInsets.zero;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        Padding(padding: padding, child: child),
      ],
    );
  }
}
