import 'package:flutter/material.dart';

class RatingInputDialog extends StatefulWidget {
  final double initialValue;

  const RatingInputDialog({super.key, required this.initialValue});

  @override
  State<RatingInputDialog> createState() => _RatingInputDialogState();
}

class _RatingInputDialogState extends State<RatingInputDialog> {
  double _currentRating = 0;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialValue.clamp(0, 5).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('¿Qué te pareció?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          _StarSelector(
            value: _currentRating,
            onChanged: (value) => setState(() => _currentRating = value),
          ),
          const SizedBox(height: 12),
          Text(
            _currentRating > 0
                ? '${_currentRating.toStringAsFixed(1)} / 5.0'
                : 'Sin calificar',
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Ahora no'),
        ),
        FilledButton(
          onPressed: _currentRating <= 0
              ? null
              : () => Navigator.of(context).pop(_currentRating),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class _StarSelector extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _StarSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.tertiary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isFilled = starValue <= value;
        return SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            padding: EdgeInsets.zero,
            splashRadius: 20,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            onPressed: () => onChanged(starValue.toDouble()),
            icon: Icon(
              isFilled ? Icons.star : Icons.star_border,
              color: color,
              size: 28,
            ),
          ),
        );
      }),
    );
  }
}
