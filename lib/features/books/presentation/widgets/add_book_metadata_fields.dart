import 'package:flutter/material.dart';

class AddBookMetadataFields extends StatelessWidget {
  final GlobalKey titleFieldKey;
  final TextEditingController titleController;
  final TextEditingController authorController;
  final FocusNode titleFocusNode;
  final FocusNode authorFocusNode;
  final VoidCallback onTitleChanged;
  final VoidCallback onAuthorChanged;

  const AddBookMetadataFields({
    super.key,
    required this.titleFieldKey,
    required this.titleController,
    required this.authorController,
    required this.titleFocusNode,
    required this.authorFocusNode,
    required this.onTitleChanged,
    required this.onAuthorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KeyedSubtree(
          key: titleFieldKey,
          child: TextFormField(
            controller: titleController,
            focusNode: titleFocusNode,
            validator: (value) =>
                (value ?? '').trim().isEmpty ? 'Título requerido' : null,
            decoration: InputDecoration(
              labelText: 'Título *',
              helperText: 'Escribe el título tal como aparece en la portada',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.book),
            ),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            onChanged: (_) => onTitleChanged(),
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: authorController,
          focusNode: authorFocusNode,
          decoration: InputDecoration(
            labelText: 'Autor',
            helperText: 'Opcional: ayúdanos a organizar tus lecturas',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.person),
          ),
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.name],
          onChanged: (_) => onAuthorChanged(),
        ),
      ],
    );
  }
}
