import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../utils/open_external_downloads.dart';
import '../providers/finance_provider.dart';
import '../services/notification_service.dart';
import '../widgets/uangky_logo.dart';

/// Pengaturan: pengingat, reload/reset data, salin JSON, tentang app. Data provider dibaca lewat [read] saat aksi (tanpa [watch] di build).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool? _reminderOn;
  bool _loadingReminder = true;

  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    final v = await NotificationService.instance.isDailyReminderEnabled();
    if (mounted) {
      setState(() {
        _reminderOn = v;
        _loadingReminder = false;
      });
    }
  }

  Future<void> _setReminder(bool v) async {
    await NotificationService.instance.setDailyReminderEnabled(v);
    if (mounted) setState(() => _reminderOn = v);
  }

  @override
  Widget build(BuildContext context) {
    final mobile = NotificationService.supportsDailyReminder;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_loadingReminder)
            const LinearProgressIndicator(minHeight: 2)
          else
            SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined),
              title: const Text('Pengingat harian'),
              subtitle: Text(
                mobile
                    ? 'Notifikasi lokal sekali sehari — buka app untuk cek jadwal & transaksi.'
                    : 'Tersedia di Android / iOS. Di desktop & web tidak dijadwalkan.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: _reminderOn ?? false,
              onChanged: mobile
                  ? (v) async {
                      await _setReminder(v);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(v ? 'Pengingat diaktifkan' : 'Pengingat dimatikan')),
                        );
                      }
                    }
                  : null,
            ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.cloud_download_outlined),
            title: const Text('Muat ulang dari penyimpanan'),
            subtitle: const Text('Sinkronkan tampilan dengan data lokal'),
            onTap: () async {
              await context.read<FinanceProvider>().reloadFromDisk();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data dimuat ulang')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Kembalikan data demo'),
            subtitle: const Text('Mengganti data saat ini dengan contoh awal'),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Reset ke demo?'),
                  content: const Text('Data yang tersimpan akan diganti contoh bawaan.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                    FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ya')),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                await context.read<FinanceProvider>().resetToDemo();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data demo dipulihkan')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy_all_outlined),
            title: const Text('Salin cadangan JSON'),
            subtitle: const Text('Untuk pindah perangkat manual'),
            onTap: () {
              final fin = context.read<FinanceProvider>();
              final payload = {
                'ledgers': fin.ledgers.map((e) => e.toJson()).toList(),
                'transactions': fin.transactions.map((e) => e.toJson()).toList(),
                'schedules': fin.schedules.map((e) => e.toJson()).toList(),
              };
              final text = const JsonEncoder.withIndent('  ').convert(payload);
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cadangan disalin ke clipboard')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined),
            title: const Text('Hapus semua data lokal'),
            subtitle: const Text('Tidak dapat dibatalkan'),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Hapus semua?'),
                  content: const Text('Semua buku, transaksi, dan jadwal di perangkat ini akan dihapus.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                await context.read<FinanceProvider>().clearAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Penyimpanan dikosongkan')),
                  );
                }
              }
            },
          ),
          if (kIsWeb)
            ListTile(
              leading: const Icon(Icons.android),
              title: const Text('Unduh APK Android'),
              subtitle: const Text('File di Google Drive (bukan Play Store)'),
              onTap: openUangKyApkDirectDownload,
            ),
          const Divider(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: UangkyLogo(variant: UangkyLogoVariant.transparent, size: 72),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Tentang UangKy',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Data disimpan lokal di perangkat (SharedPreferences). '
                    'Tidak ada server cloud bawaan — cocok untuk privasi ringkas di APK Android.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Text('Versi 1.0.0', style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
