import 'package:atiora/core/utils/helpers.dart';
import 'package:flutter/material.dart';

class StateModal extends StatelessWidget {
  final List<String> estados;
  final int seleccionado;
  final Function(int) onSeleccionar;

  const StateModal({
    super.key,
    required this.estados,
    required this.seleccionado,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleLarge;
    final subtitleStyle = theme.textTheme.bodyMedium;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Cambiar estado",
                style: titleStyle?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text("Se actualizará en la base de datos", style: subtitleStyle),
              const SizedBox(height: 18),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: estados.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    thickness: 0.6,
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                  itemBuilder: (context, index) {
                    final statusColor = AppHelpers.getStatusColor(
                      estados[index],
                    );
                    final isSelected = index == seleccionado;
                    return ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -2),
                      minVerticalPadding: 6,
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(
                            theme.brightness == Brightness.dark ? 0.25 : 0.12,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: statusColor.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Icon(Icons.circle, color: statusColor, size: 12),
                      ),
                      title: Text(
                        estados[index].toUpperCase(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: theme.colorScheme.primary)
                          : null,
                      onTap: () => _confirmarCambio(context, index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmarCambio(BuildContext context, int nuevoIndex) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirmar estado"),
        content: Text(
          "¿Deseas actualizar el estado del libro?",
          style: Theme.of(dialogContext).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Guardar"),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      onSeleccionar(nuevoIndex);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}
