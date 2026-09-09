import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/logo_mark.dart';

const _kLogoSize = 28.0;
const _kGap = 12.0;
const _kWordmark = '60·SECONDS';

double _measureTextWidth(String text, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  return painter.width;
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  // Sequential phases on one timeline:
  // 1. hold — the full wordmark sits still so it can actually be read.
  // 2. backspace — it erases from the right, one character at a time, at a
  //    steady (linear) pace, each character fading out as it goes rather
  //    than vanishing in a hard cut.
  // 3. move — with the text gone, the clock slides into true center.
  // 4. fade — the clock fades out just before handing off to Home.
  late final Animation<double> _backspace;
  late final Animation<double> _move;
  late final Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );
    _backspace = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.12, 0.62, curve: Curves.linear),
    );
    _move = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.68, 0.88, curve: Curves.easeInOutCubic),
    );
    _fadeOut = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.92, 1.0, curve: Curves.easeOut),
    );
    _controller.forward().whenComplete(() {
      if (mounted) context.go('/');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textStyle = AppTypography.label(
      fontSize: 18,
      color: AppColors.textPrimary,
    );
    final fullTextWidth = _measureTextWidth(_kWordmark, textStyle);

    final pairedIconLeft =
        (screenWidth - (_kLogoSize + _kGap + fullTextWidth)) / 2;
    final centeredIconLeft = (screenWidth - _kLogoSize) / 2;
    final textLeft = pairedIconLeft + _kLogoSize + _kGap;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          // How far the erase has progressed, in fractional characters —
          // e.g. 3.4 means 3 characters fully gone and the 4th 40% faded.
          final erasedT = (_backspace.value * _kWordmark.length).clamp(
            0.0,
            _kWordmark.length.toDouble(),
          );
          final wholeErased = erasedT.floor();
          final visibleLen = _kWordmark.length - wholeErased;
          final fadingCharOpacity = 1 - (erasedT - wholeErased);

          final iconLeft = _lerp(
            pairedIconLeft,
            centeredIconLeft,
            _move.value,
          );
          final iconOpacity = 1 - _fadeOut.value;

          return Stack(
            children: [
              if (visibleLen > 0)
                Positioned(
                  left: textLeft,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (visibleLen > 1)
                          Text(
                            _kWordmark.substring(0, visibleLen - 1),
                            style: textStyle,
                          ),
                        Opacity(
                          opacity: fadingCharOpacity,
                          child: Text(
                            _kWordmark[visibleLen - 1],
                            style: textStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                left: iconLeft,
                top: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Opacity(
                    opacity: iconOpacity,
                    child: const LogoMark(size: _kLogoSize),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
