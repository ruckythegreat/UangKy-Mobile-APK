import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'uangky_logo.dart';

/// Layar pembuka saat [FinanceProvider] belum siap — logo transparan + gradien merek.
class BrandedSplash extends StatelessWidget {
  const BrandedSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF8F2),
              AppColors.peach,
              AppColors.scaffold,
            ],
            stops: [0.0, 0.42, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1C1917).withValues(alpha: 0.12),
                        blurRadius: 32,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(28)),
                    child: ColoredBox(
                      color: Color(0x26FFFFFF),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: UangkyLogo(variant: UangkyLogoVariant.transparent, size: 120),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'UangKy',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: const Color(0xFF1C1917),
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Catatan keuangan ringan',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF57534E),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 36),
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(0xFF1C1917),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
