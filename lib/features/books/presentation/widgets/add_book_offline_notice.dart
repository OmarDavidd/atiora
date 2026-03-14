import 'package:flutter/material.dart';

class AddBookOfflineQueueNotice extends StatelessWidget {
  final bool isOffline;
  final bool hasPendingQueue;

  const AddBookOfflineQueueNotice({
    super.key,
    required this.isOffline,
    required this.hasPendingQueue,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = isOffline
        ? 'Sin conexión: guardaremos el libro y se sincronizará al volver la red.'
        : 'Tienes cambios pendientes por sincronizar; mantén la app abierta.';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, color: colors.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
