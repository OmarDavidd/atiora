import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProgressInputDialog extends StatefulWidget {
  final int initialPage;
  final int totalPages;

  const ProgressInputDialog({
    super.key,
    required this.initialPage,
    required this.totalPages,
  });

  @override
  State<ProgressInputDialog> createState() => _ProgressInputDialogState();
}

class _ProgressInputDialogState extends State<ProgressInputDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialPage.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxPage = widget.totalPages;
    return AlertDialog(
      title: const Text('Actualiza tu progreso'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(labelText: 'Página actual (0-$maxPage)'),
          validator: (value) {
            final text = value?.trim();
            if (text == null || text.isEmpty) {
              return 'Ingresa un número válido';
            }
            final page = int.tryParse(text);
            if (page == null) {
              return 'Solo números';
            }
            if (page < 0 || page > maxPage) {
              return 'Debe estar entre 0 y $maxPage';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() != true) return;
            final value = int.tryParse(_controller.text.trim());
            Navigator.of(context).pop(value);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
