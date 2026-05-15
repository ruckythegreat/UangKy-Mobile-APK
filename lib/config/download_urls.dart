/// Tautan unduhan APK (Google Drive), bukan Play Store.
abstract final class UangKyDownloadUrls {
  static const String _apkDriveFileId = '1BohGM4ucLC7adbyZXDQML-ECysOaOr09';

  /// Unduhan langsung (format resmi Drive). Untuk file besar, Drive kadang menampilkan halaman konfirmasi dulu.
  static const String androidApkDirect =
      'https://drive.google.com/uc?export=download&id=$_apkDriveFileId';

  /// Halaman file di Drive (buka di tab baru bila unduhan langsung macet).
  static const String androidApkViewPage =
      'https://drive.google.com/file/d/$_apkDriveFileId/view?usp=drive_link';
}
