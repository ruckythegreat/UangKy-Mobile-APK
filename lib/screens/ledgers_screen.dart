import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ledger.dart';
import '../providers/finance_provider.dart';
import '../theme/app_colors.dart';
import '../utils/color_parse.dart';
import '../utils/currency_format.dart';

/// Tab Buku: daftar buku + dialog buat buku baru. Detail buku dibuka lewat [ShellScreen].
class LedgersScreen extends StatelessWidget {
  const LedgersScreen({super.key, required this.onOpenLedger});

  final void Function(String ledgerId) onOpenLedger;

  static const _presetColors = [
    '#FF3B30',
    '#34C759',
    '#007AFF',
    '#AF52DE',
    '#FF9500',
    '#5AC8FA',
    '#FF8A80',
    '#FFCC99',
  ];

  static const _typeSuggestions = [
    'Personal',
    'Usaha',
    'Bendahara',
    'Warung',
    'Lainnya',
  ];

  Future<void> _showAddLedgerDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final typeCtrl = TextEditingController(text: 'Personal');
    final iconCtrl = TextEditingController(text: '📘');
    var colorHex = _presetColors.first;

    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setLocal) => AlertDialog(
            title: const Text(
              'Buku baru',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nama buku'),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: typeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Jenis / peran',
                      hintText: 'Contoh: Personal',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final t in _typeSuggestions)
                        ActionChip(
                          label: Text(t, style: const TextStyle(fontSize: 12)),
                          onPressed: () => typeCtrl.text = t,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: iconCtrl,
                    maxLength: 2,
                    decoration: const InputDecoration(
                      labelText: 'Ikon (emoji)',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Warna aksen',
                    style: Theme.of(ctx).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in _presetColors)
                        InkWell(
                          onTap: () => setLocal(() => colorHex = c),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: parseHexColor(c),
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: colorHex == c ? 3 : 1,
                                color: colorHex == c
                                    ? AppColors.inkPrimary
                                    : AppColors.inkScrim,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty) return;
                  Navigator.pop(ctx, true);
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      );

      if (ok == true && context.mounted) {
        final name = nameCtrl.text.trim();
        if (name.isEmpty) return;
        final icon = iconCtrl.text.trim().isEmpty ? '📘' : iconCtrl.text.trim();
        final ledger = Ledger(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          type: typeCtrl.text.trim().isEmpty ? 'Lainnya' : typeCtrl.text.trim(),
          icon: icon,
          color: colorHex,
        );
        await context.read<FinanceProvider>().addLedger(ledger);
      }
    } finally {
      nameCtrl.dispose();
      typeCtrl.dispose();
      iconCtrl.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fin = context.watch<FinanceProvider>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buku keuangan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkPrimary,
                    ),
                  ),
                  Text(
                    'Pilih buku atau buat baru',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
                  ),
                ],
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: () => _showAddLedgerDialog(context),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Buku baru'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...fin.ledgers.map((ledger) {
          final balance = fin.ledgerBalance(ledger.id);
          final count = fin.transactions
              .where((t) => t.ledgerId == ledger.id)
              .length;
          final tint = parseHexColor(ledger.color, opacity: 0.28);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: AppColors.surfaceGlass,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => onOpenLedger(ledger.id),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: tint,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          ledger.icon,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ledger.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              ledger.type,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.inkMuted,
                              ),
                            ),
                            Text(
                              '$count transaksi',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatIdr(balance),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Saldo',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.inkMuted.withValues(alpha: 0.65),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              'Tip: ketuk buku untuk riwayat; ikon hapus di detail untuk hapus transaksi.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
            ),
          ),
        ),
      ],
    );
  }
}
