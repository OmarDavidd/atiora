import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:atiora/core/utils/app_colors.dart';
import 'package:atiora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashGate extends StatefulWidget {
  final Widget child;

  const SplashGate({super.key, required this.child});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  bool _showSplash = true;
  bool _authReady = false;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _authReady = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkHide();
    });
  }

  void _checkHide() {
    final elapsed = DateTime.now().difference(_startTime!).inMilliseconds;
    if (_authReady && elapsed >= 2000) {
      if (mounted) setState(() => _showSplash = false);
    } else if (_authReady) {
      final remaining = 2000 - elapsed;
      Future.delayed(Duration(milliseconds: remaining), () {
        if (mounted) setState(() => _showSplash = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated || state is AuthInitial) {
          _authReady = true;
          _checkHide();
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _showSplash
            ? const BrandSplashScreen(key: ValueKey('brand-splash'))
            : KeyedSubtree(
                key: const ValueKey('atiora-app'),
                child: widget.child,
              ),
      ),
    );
  }
}

class BrandSplashScreen extends StatelessWidget {
  const BrandSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.3),
                    AppColors.primaryDark.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'Atiora',
                  textStyle: GoogleFonts.jaini(
                    fontSize: 56,
                    letterSpacing: 8,
                    color: Colors.white,
                  ),
                  speed: const Duration(milliseconds: 150),
                ),
              ],
              totalRepeatCount: 1,
            ),
          ),
        ],
      ),
    );
  }
}
