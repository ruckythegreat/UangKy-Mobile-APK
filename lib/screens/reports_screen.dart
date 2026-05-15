import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/transaction.dart';
import '../providers/finance_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_format.dart';
import '../utils/csv_export.dart';

/// Laporan per bulan: ringkas masuk/keluar/net, filter, daftar transaksi, ekspor CSV.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late DateTime _month;
  String _ledgerFilter = 'all';
  String _categoryFilter = 'all';

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _month = DateTime(n.year, n.month);
  }

  String get _monthKey =>
      '${_month.year.toString().padLeft(4, '0')}-${_month.month.toString().padLeft(2, '0')}';

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _month,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _month = DateTime(picked.year, picked.month));
    }
  }

  Future<void> _exportCsv(List<Transaction> rows) async {
    final fin = context.read<FinanceProvider>();
    final csv = buildCsv(transactions: rows, ledgers: fin.ledgers);
    final name = 'laporan-$_monthKey.csv';
    await Share.share(csv, subject: name);
  }

  @override
  Widget build(BuildContext context) {
    final fin = context.watch<FinanceProvider>();
    final categories = fin.transactions.map((t) => t.category).toSet().toList()..sort();

    final filtered = fin.transactions.where((t) {
      if (!t.date.startsWith(_monthKey)) return false;
      if (_ledgerFilter != 'all' && t.ledgerId != _ledgerFilter) return false;
      if (_categoryFilter != 'all' && t.category != _categoryFilter) return false;
      return true;
    }).toList();

    var income = 0.0;
    var expense = 0.0;
    for (final t in filtered) {
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    final net = income - expense;

    final sorted = filtered..sort((a, b) => b.date.compareTo(a.date));

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Laporan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1C1917),
                      ),
                ),
                Text(
                  'Filter bulan & buku, lalu bagikan CSV',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF78716C),
                      ),
                ),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filter',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF44403C),
                              ),
                        ),
                        const SizedBox(height: 10),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Bulan'),
                          subtitle: Text(
                            '${_month.month}/${_month.year}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: const Icon(Icons.calendar_month),
                          onTap: _pickMonth,
                        ),
                        DropdownButtonFormField<String>(
                          value: _ledgerFilter,
                          decoration: const InputDecoration(labelText: 'Buku'),
                          items: [
                            const DropdownMenuItem(value: 'all', child: Text('Semua buku')),
                            for (final l in fin.ledgers)
                              DropdownMenuItem(value: l.id, child: Text('${l.icon} ${l.name}')),
                          ],
                          onChanged: (v) => setState(() => _ledgerFilter = v ?? 'all'),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _categoryFilter,
                          decoration: const InputDecoration(labelText: 'Kategori'),
                          items: [
                            const DropdownMenuItem(value: 'all', child: Text('Semua kategori')),
                            for (final c in categories)
                              DropdownMenuItem(value: c, child: Text(c)),
                          ],
                          onChanged: (v) => setState(() => _categoryFilter = v ?? 'all'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        label: 'Masuk',
                        value: formatIdr(income),
                        bg: AppColors.incomeGreen.withValues(alpha: 0.14),
                        fg: AppColors.incomeGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatTile(
                        label: 'Keluar',
                        value: formatIdr(expense),
                        bg: AppColors.expenseRed.withValues(alpha: 0.14),
                        fg: AppColors.expenseRed,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatTile(
                        label: 'Net',
                        value: formatIdr(net),
                        bg: AppColors.surfaceMuted.withValues(alpha: 0.6),
                        fg: net >= 0 ? AppColors.incomeGreen : AppColors.expenseRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: sorted.isEmpty ? null : () => _exportCsv(sorted),
                  icon: const Icon(Icons.download),
                  label: const Text('Ekspor / bagikan CSV'),
                ),
                const SizedBox(height: 18),
                Text(
                  'Transaksi (${sorted.length})',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF44403C),
                      ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        if (sorted.isEmpty)
          SliverToBoxAdapter(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Tidak ada transaksi untuk filter ini',
                    style: TextStyle(color: Colors.black.withValues(alpha: 0.55)),
                  ),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList.separated(
              itemCount: sorted.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final t = sorted[i];
                final ledger = fin.ledgerById(t.ledgerId);
                final pos = t.type == 'income';
                return Card(
                  child: ListTile(
                    title: Text(t.category, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${ledger?.icon ?? ''} ${ledger?.name ?? '-'} • ${t.date}'),
                    trailing: Text(
                      '${pos ? '+' : '-'}${formatIdr(t.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: pos ? AppColors.incomeGreen : AppColors.expenseRed,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.bg,
    required this.fg,
  });

  final String label;
  final String value;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: fg.withValues(alpha: 0.75)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
          ),
        ],
      ),
    );
  }
}
