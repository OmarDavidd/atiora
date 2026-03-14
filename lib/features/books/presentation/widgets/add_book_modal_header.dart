import 'package:flutter/material.dart';

class AddBookModalHeader extends StatelessWidget {
  final VoidCallback onClose;

  const AddBookModalHeader({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Añadir libro',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const Spacer(flex: 2),
        IconButton(
          tooltip: 'Cerrar',
          onPressed: onClose,
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}
