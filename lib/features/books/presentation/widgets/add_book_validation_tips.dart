import 'package:flutter/material.dart';

class AddBookValidationTip {
  final String id;
  final String message;
  final VoidCallback? onTap;

  const AddBookValidationTip({
    required this.id,
    required this.message,
    this.onTap,
  });
}

class AddBookValidationTipsWrap extends StatelessWidget {
  final List<AddBookValidationTip> validationTips;

  const AddBookValidationTipsWrap({super.key, required this.validationTips});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Wrap(
        key: ValueKey(validationTips.length),
        spacing: 8,
        runSpacing: 8,
        children: validationTips
            .map(
              (tip) =>
                  InputChip(label: Text(tip.message), onPressed: tip.onTap),
            )
            .toList(),
      ),
    );
  }
}
