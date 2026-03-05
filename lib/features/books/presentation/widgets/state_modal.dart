import 'package:atiora/core/utils/app_colors.dart';
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
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cambiar estado",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral0,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Se actualizará en la base de datos",
                style: TextStyle(fontSize: 14, color: AppColors.neutral400),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: estados.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(
                estados[index].toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              leading: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppHelpers.getStatusColor(
                    estados[index],
                  ).withValues(alpha: (0.15)),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppHelpers.getStatusColor(
                      estados[index],
                    ).withValues(alpha: (0.3)),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.circle,
                  color: AppHelpers.getStatusColor(estados[index]),
                  size: 14,
                ),
              ),
              trailing: index == seleccionado
                  ? Icon(Icons.check, color: Colors.green, size: 24)
                  : null,
              onTap: () => _confirmarCambio(context, index),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmarCambio(BuildContext context, int nuevoIndex) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Confirmar estado"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text("Guardar", style: TextStyle(color: Colors.white)),
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
