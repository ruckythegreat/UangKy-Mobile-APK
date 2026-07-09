import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/open_external_downloads.dart';
import 'uangky_logo.dart';

/// Banner khusus web: unduh APK untuk pengalaman & penyimpanan lebih stabil.
class WebMobileDownloadBanner extends StatelessWidget {
  const WebMobileDownloadBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();
    return Material(
      color: AppColors.inkPrimary,
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, c) {
            final narrow = c.maxWidth < 420;
            final text = Text(
              narrow
                  ? 'Unduh APK untuk penyimpanan stabil di ponsel.'
                  : 'Versi web ringkas. Unduh APK Android untuk penyimpanan stabil.',
              style: TextStyle(
                color: AppColors.onInk.withValues(alpha: 0.92),
                fontSize: 12,
                height: 1.25,
              ),
            );
            final actions = Row(
              mainAxisSize: narrow ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (narrow)
                  Expanded(
                    child: TextButton(
                      onPressed: openUangKyApkDirectDownload,
                      child: const Text(
                        'Unduh APK',
                        style: TextStyle(
                          color: AppColors.peach,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                else
                  TextButton(
                    onPressed: openUangKyApkDirectDownload,
                    child: const Text(
                      'Unduh APK',
                      style: TextStyle(
                        color: AppColors.peach,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                if (!narrow)
                  TextButton(
                    onPressed: openUangKyApkInDrive,
                    child: const Text(
                      'Drive',
                      style: TextStyle(
                        color: AppColors.peach,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            );
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: narrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const UangkyLogo(
                              variant: UangkyLogoVariant.solid,
                              size: 34,
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: text),
                          ],
                        ),
                        const SizedBox(height: 6),
                        actions,
                      ],
                    )
                  : Row(
                      children: [
                        const UangkyLogo(
                          variant: UangkyLogoVariant.solid,
                          size: 34,
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: text),
                        actions,
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}
