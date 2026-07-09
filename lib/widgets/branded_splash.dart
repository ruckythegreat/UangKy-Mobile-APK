import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'uangky_logo.dart';

/// Layar pembuka saat [FinanceProvider] belum siap — logo transparan + gradien merek.
class BrandedSplash extends StatelessWidget {
  const BrandedSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: ColoredBox(
        color: AppColors.scaffold,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.borderSoft),
                  ),
                  child: const ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(28)),
                    child: ColoredBox(
                      color: AppColors.surfaceGlass,
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: UangkyLogo(
                          variant: UangkyLogoVariant.transparent,
                          size: 120,
                        ),
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
                    color: AppColors.inkPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Catatan keuangan ringan',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.inkMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 36),
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.inkPrimary,
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
