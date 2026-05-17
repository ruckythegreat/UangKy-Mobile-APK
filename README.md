# UangKy

Aplikasi catatan keuangan Flutter (multi buku, transaksi, laporan, ekspor CSV, jadwal berulang). Data disimpan **lokal** lewat `shared_preferences` (JSON satu kunci).

---

## Peta UI → file kode (cepat cari komponen)

| Elemen UI | File & penjelasan singkat |
|-----------|---------------------------|
| **Area aman status bar atas** | `shell_screen.dart` — `SafeArea(top: true)` membungkus isi body supaya judul tidak nabrak jam/baterai. |
| **Banner unduh (web)** | `widgets/web_mobile_download_banner.dart` — hanya relevan build web. |
| **Tombol “Catat” (FAB extended)** | `shell_screen.dart` — bukan `floatingActionButton` Scaffold; ditempatkan **di atas** `NavigationBar` agar tidak menutup tab “Laporan”. |
| **Navbar bawah (Beranda / Buku / Jadwal / Laporan)** | `shell_screen.dart` — `NavigationBar` + isi tab **hanya tab aktif** (lazy, ringan). |
| **Isi tab Beranda** | `screens/dashboard_screen.dart` — header, total saldo, ringkasan buku, grafik + filter, transaksi terbaru. |
| **Isi tab Buku (daftar)** | `screens/ledgers_screen.dart` — tombol “Buku baru”, daftar kartu buku. |
| **Detail satu buku** | `screens/ledger_detail_screen.dart` — saldo buku, riwayat, tap baris = ubah, ikon tempat sampah = hapus. |
| **Tab Jadwal** | `screens/scheduling_screen.dart` |
| **Tab Laporan** | `screens/reports_screen.dart` |
| **Form tambah / ubah transaksi** | `screens/add_transaction_screen.dart` — parameter `existing` untuk mode edit. |
| **Pengaturan (ikon gear di Beranda)** | `screens/settings_screen.dart` — muat ulang, reset demo, cadangan JSON, **pengingat harian**. |
| **Warna & tema global** | `theme/app_theme.dart`, `theme/app_colors.dart` |
| **State & simpan data** | `providers/finance_provider.dart` + `services/storage_service.dart` |
| **Notifikasi lokal** | `services/notification_service.dart` — diinisialisasi dari `main.dart`. |

---

## Alur kerja aplikasi

Urutan saat user memakai app:

1. **User buka app** → OS menjalankan proses Flutter.
2. **`main.dart`** → `WidgetsFlutterBinding.ensureInitialized()`, **`NotificationService.instance.init()`** (aman di web/desktop), orientasi (non-web), lalu `runApp(UangKyApp())`.
3. **`app.dart`** → `ChangeNotifierProvider` membuat **satu** `FinanceProvider`. `MaterialApp` menampilkan `_AppLoader`.
4. **`_AppLoader`** → menunggu `FinanceProvider.isReady == true`. Setelah siap → **`ShellScreen`**.
5. **Provider load data** → `_bootstrap()`: baca JSON; kalau kosong, seed demo lalu simpan.
6. **UI tampil** → screen yang perlu data memakai `context.watch<FinanceProvider>()` atau `read` sesuai kebutuhan.
7. **User ubah data** → panggil method provider (`addTransaction`, `updateTransaction`, `deleteTransaction`, `addLedger`, …) → `notifyListeners()` → UI rebuild.
8. **Persist** → `_persist()` → `StorageService.savePayload(...)`.

**Ringkas:** satu sumber kebenaran = `FinanceProvider`; storage = snapshot JSON.

---

## Kenapa tidak pakai `Timer.periodic` untuk jadwal?

Jadwal otomatis dicek saat **frame pertama shell** dan saat lifecycle **`resumed`** (`shell_screen.dart` → `checkDueSchedules()`), bukan polling timer (hemat baterai, perilaku stabil).

**Pelengkap:** pengingat **notifikasi lokal harian** (opsional di Pengaturan, Android/iOS) mengingatkan user membuka app; eksekusi jadwal tetap saat app jalan / resume.

---

## Struktur folder (`lib/`)

| Path | Peran |
|------|--------|
| `main.dart` | Entry + `NotificationService.init`. |
| `app.dart` | Provider, tema, loader → shell. |
| `providers/finance_provider.dart` | State, persist, jadwal, CRUD transaksi/buku. |
| `services/storage_service.dart` | JSON `SharedPreferences`. |
| `services/notification_service.dart` | Pengingat harian (platform terbatas). |
| `models/` | `Ledger`, `Transaction`, `Schedule`. |
| `screens/` | Layar per tab / flow. |
| `widgets/` | Komponen reusable. |
| `theme/` | Tema Material 3. |
| `utils/` | Format IDR, CSV, dll. |

---

## Provider: method penting

- **`addTransaction` / `updateTransaction` / `deleteTransaction`** — ubah daftar transaksi + persist.
- **`addLedger`** — buku baru (dari dialog di tab Buku).
- **`checkDueSchedules()`** — jadwal → transaksi otomatis (buka/resume app).
- **`reloadFromDisk()`**, **`resetToDemo()`**, **`clearAll()`** — sesuai nama.

---

## Deploy (GitHub + Vercel + APK Drive)

Lihat **`DEPLOY.md`**: push ke GitHub, secrets Vercel, workflow GitHub Actions, dan opsi deploy manual. Unduhan APK dari app web memakai **Google Drive** (bukan Play Store); URL diatur di `lib/config/download_urls.dart`.

---

## Menjalankan project

```bash
flutter pub get
flutter run
```

---

## Paket utama

- **`provider`**, **`shared_preferences`**, **`fl_chart`**, **`url_launcher`**, **`share_plus`**
- **`flutter_local_notifications`** — pengingat harian (Android/iOS; di Windows init dilewati).

---


