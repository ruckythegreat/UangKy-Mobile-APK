import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/open_external_downloads.dart';
import 'uangky_logo.dart';

/// Banner khusus web: unduh APK untuk pengalaman & penyimpanan lebih stabil.
class WebMobileDownloadBanner extends StatelessWidget {
  const WebMobileDownloadBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();
    return Material(
      color: Colors.black,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                child: ColoredBox(
                  color: Color(0x22FFFFFF),
                  child: Padding(
                    padding: EdgeInsets.all(2),
                    child: UangkyLogo(variant: UangkyLogoVariant.solid, size: 34),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Versi web ringkas. Untuk penyimpanan stabil di ponsel, unduh APK Android (Google Drive).',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
              ),
              TextButton(
                onPressed: openUangKyApkDirectDownload,
                child: const Text(
                  'Unduh APK',
                  style: TextStyle(
                    color: Color(0xFFFFCC99),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: openUangKyApkInDrive,
                child: const Text(
                  'Drive',
                  style: TextStyle(
                    color: Color(0xFFFFCC99),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
