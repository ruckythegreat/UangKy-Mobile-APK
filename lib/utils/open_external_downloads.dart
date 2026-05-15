import 'package:url_launcher/url_launcher.dart';

import '../config/download_urls.dart';

/// Buka unduhan APK via Google Drive (`uc?export=download`).
Future<void> openUangKyApkDirectDownload() async {
  final uri = Uri.parse(UangKyDownloadUrls.androidApkDirect);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Buka halaman file di Drive (jika unduhan langsung macet / peringatan virus scan).
Future<void> openUangKyApkInDrive() async {
  final uri = Uri.parse(UangKyDownloadUrls.androidApkViewPage);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
