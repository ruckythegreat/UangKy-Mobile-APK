import 'package:flutter/material.dart';

import '../theme/app_assets.dart';

/// Varian logo untuk UI in-app.
enum UangkyLogoVariant {
  /// Logo transparan — cocok di atas warna solid / gradien.
  transparent,

  /// Logo dengan latar (PNG) — cocok di area terang polos.
  solid,
}

/// Logo UangKy dengan fallback aman jika aset gagal dimuat.
class UangkyLogo extends StatelessWidget {
  const UangkyLogo({
    super.key,
    this.variant = UangkyLogoVariant.transparent,
    this.size = 48,
    this.fit = BoxFit.contain,
  });

  final UangkyLogoVariant variant;
  final double size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final path = variant == UangkyLogoVariant.transparent ? AppAssets.logoTransparent : AppAssets.logoSolid;
    return RepaintBoundary(
      child: Image.asset(
        path,
        width: size,
        height: size,
        fit: fit,
        gaplessPlayback: true,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.savings_outlined,
          size: size * 0.72,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
