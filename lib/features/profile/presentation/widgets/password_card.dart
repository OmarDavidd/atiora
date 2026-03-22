import 'package:flutter/material.dart';

import 'package:atiora/core/di/injection_container.dart';
import 'package:atiora/core/di/providers/auth_provider.dart';
import 'profile_action_card.dart';

class PasswordCard extends StatelessWidget {
  const PasswordCard({super.key});

  void _openSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark
          ? Theme.of(context).colorScheme.surface
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: const _PasswordFormSheet(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ProfileActionCard(
      icon: Icons.lock_reset,
      label: 'Actualizar contraseña',
      helper: 'Refresca tu clave de acceso',
      iconColor: colors.primary,
      onTap: () => _openSheet(context),
    );
  }
}

class _PasswordFormSheet extends StatefulWidget {
  const _PasswordFormSheet();

  @override
  State<_PasswordFormSheet> createState() => _PasswordFormSheetState();
}

class _PasswordFormSheetState extends State<_PasswordFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('¿Actualizar contraseña?'),
            content: const Text(
              'Tu contraseña será actualizada inmediatamente. '
              '¿Deseas continuar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Estoy seguro'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await sl<AuthProvider>().updatePassword(_passwordController.text);
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada con éxito')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No pudimos actualizar la contraseña')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nueva contraseña',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Recuerda usar al menos 8 caracteres con números y letras.',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _passwordController,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Contraseña segura',
              filled: true,
              fillColor: isDark
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa una contraseña';
              }
              if (value.length < 8) {
                return 'Debe tener al menos 8 caracteres';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isLoading ? null : _handleSubmit,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Actualizar contraseña'),
          ),
        ),
      ],
    );
  }
}
