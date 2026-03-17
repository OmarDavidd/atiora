import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:atiora/data/models/user_model.dart';
import 'package:atiora/features/auth/presentation/bloc/auth_bloc.dart';

import '../widgets/profile_header.dart';
import '../widgets/theme_toggle_card.dart';
import '../widgets/profile_action_card.dart';
import '../widgets/password_card.dart';
import '../widgets/about_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 24,
        title: Text(
          'Perfil',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AuthAuthenticated) {
            return _ProfileContent(user: state.user);
          }
          return const _ProfileSignedOut();
        },
      ),
    );
  }
}

class _ProfileSignedOut extends StatelessWidget {
  const _ProfileSignedOut();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 48),
            const SizedBox(height: 16),
            Text(
              'Inicia sesión para ver tu perfil',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final UserModel user;

  const _ProfileContent({required this.user});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileHeader(user: user),
          const SizedBox(height: 32),
          Text(
            'Preferencias',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          const ThemeToggleCard(),
          const SizedBox(height: 32),
          Text(
            'Sesión',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ProfileActionCard(
            icon: Icons.logout,
            label: 'Cerrar sesión',
            helper: 'Salir de Atiora en este dispositivo',
            iconColor: Theme.of(context).colorScheme.error,
            onTap: () => context.read<AuthBloc>().add(SignOutEvent()),
          ),
          const SizedBox(height: 16),
          const PasswordCard(),
          const SizedBox(height: 32),
          const AboutCard(),
        ],
      ),
    );
  }
}
