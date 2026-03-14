import 'package:flutter/material.dart';

class AddBookActionsSection extends StatelessWidget {
  final bool isLoading;
  final bool canReset;
  final VoidCallback onSave;
  final VoidCallback onReset;
  final VoidCallback onExit;

  const AddBookActionsSection({
    super.key,
    required this.isLoading,
    required this.canReset,
    required this.onSave,
    required this.onReset,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : onSave,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Guardar libro',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: isLoading || !canReset ? null : onReset,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Limpiar formulario'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (!isLoading)
          TextButton.icon(
            onPressed: onExit,
            icon: const Icon(Icons.exit_to_app_rounded),
            label: const Text('Salir sin guardar'),
          ),
      ],
    );
  }
}
