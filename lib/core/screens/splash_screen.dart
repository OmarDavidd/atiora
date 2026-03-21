import 'dart:ui';

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
  bool _authChecked = false;

  void _handleFinished() {
    if (!mounted) return;
    setState(() => _showSplash = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated || state is AuthInitial) {
          if (!_authChecked) {
            _authChecked = true;
            Future.delayed(const Duration(milliseconds: 300), _handleFinished);
          }
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        child: _showSplash
            ? BrandSplashScreen(
                key: const ValueKey('brand-splash'),
                onFinished: _handleFinished,
              )
            : KeyedSubtree(
                key: const ValueKey('atiora-app'),
                child: widget.child,
              ),
      ),
    );
  }
}

class BrandSplashScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const BrandSplashScreen({super.key, required this.onFinished});

  @override
  State<BrandSplashScreen> createState() => _BrandSplashScreenState();
}

class _BrandSplashScreenState extends State<BrandSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  late final Animation<double> _textOpacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.45, 0.9, curve: Curves.easeOut),
  );

  late final Animation<double> _textSlide = Tween<double>(begin: 18, end: 0)
      .animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.45, 0.9, curve: Curves.easeOutCubic),
        ),
      );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 200), widget.onFinished);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              Positioned.fill(child: _buildBackdrop()),
              Center(child: _buildWordmark()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackdrop() {
    final double blend = _controller.value.clamp(0.0, 1.0).toDouble();
    final topColor = Color.lerp(
      AppColors.backgroundPrimary,
      AppColors.secondary.withValues(alpha: 0.65),
      blend * 0.5,
    )!;
    final bottomColor = Color.lerp(
      AppColors.backgroundPrimary,
      AppColors.primaryDark.withValues(alpha: 0.9),
      blend,
    )!;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [topColor, bottomColor],
        ),
      ),
      child: CustomPaint(painter: _HaloPainter(blend: blend)),
    );
  }

  Widget _buildWordmark() {
    final letterSpacing = (lerpDouble(6, 18, _controller.value) ?? 10)
        .toDouble();
    final textColor = Color.lerp(
      AppColors.neutral0,
      Colors.white,
      _controller.value * 0.5,
    );

    return Opacity(
      opacity: _textOpacity.value,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: Offset(0, _textSlide.value),
            child: Text(
              'Atiora',
              style: GoogleFonts.jaini(
                fontSize: 56,
                letterSpacing: letterSpacing,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 3,
            width: 120,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.primary.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _HaloPainter extends CustomPainter {
  final double blend;

  const _HaloPainter({required this.blend});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.12 * blend)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    final center = Offset(size.width * 0.2, size.height * 0.25);
    final radius = size.width * 0.4;
    canvas.drawCircle(center, radius, paint);

    final paint2 = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.1 * blend)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    final center2 = Offset(size.width * 0.8, size.height * 0.75);
    canvas.drawCircle(center2, radius * 0.8, paint2);
  }

  @override
  bool shouldRepaint(covariant _HaloPainter oldDelegate) {
    return oldDelegate.blend != blend;
  }
}
