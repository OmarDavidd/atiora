import 'package:atiora/core/navigation/app_router.dart';
import 'package:atiora/core/utils/notification_helper.dart';
import 'package:atiora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:atiora/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        SignInEvent(_emailController.text.trim(), _passwordController.text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            NotificationHelper.showError(context, state.message);
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final colors = Theme.of(context).colorScheme;
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "ATIORA",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.jaini(
                            fontSize: 56,
                            fontWeight: FontWeight.w300,
                            color: colors.primary,
                            letterSpacing: 6,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 50),
                        AuthTextField(
                          controller: _emailController,
                          label: 'Correo electrónico',
                          hint: 'tu@email.com',
                          icon: Icons.email_outlined,
                          validator: (value) => (value?.isEmpty ?? true)
                              ? 'Email requerido'
                              : (!value!.contains('@'))
                              ? 'Email inválido'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: _passwordController,
                          label: 'Contraseña',
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          showToggle: true,
                          validator: (value) => (value?.isEmpty ?? true)
                              ? 'Contraseña requerida'
                              : (value!.length < 6)
                              ? 'Mínimo 6 caracteres'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state is AuthLoading
                                ? null
                                : () => _onLogin(context),
                            child: state is AuthLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Iniciar Sesión',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRouter.register);
                            },
                            child: const Text('¿No tienes cuenta? Regístrate'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
