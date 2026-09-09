import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LogoMark extends StatelessWidget {
  final double size;
  const LogoMark({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/logo.svg',
      width: size,
      height: size,
    );
  }
}
