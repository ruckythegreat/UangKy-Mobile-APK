import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../providers/finance_provider.dart';
import '../theme/app_colors.dart';
import '../utils/color_parse.dart';
import '../utils/currency_format.dart';
import '../widgets/uangky_logo.dart';
import 'settings_screen.dart';

/// Tab Beranda: saldo total, daftar buku, grafik arus kas, transaksi terakhir.
/// Navigasi bawah & tombol catat ada di [ShellScreen].
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.onAddTransaction,
    required this.onEditTransaction,
    required this.onOpenLedgerInBooks,
    required this.onOpenReportsTab,
  });

  final VoidCallback onAddTransaction;
  final void Function(Transaction t) onEditTransaction;
  final void Function(String ledgerId) onOpenLedgerInBooks;
  final VoidCallback onOpenReportsTab;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  /// Jumlah hari ke belakang untuk grafik (7 / 14 / 30).
  int _chartRangeDays = 7;
  /// `null` = semua buku; selain itu filter [ledgerId].
  String? _chartLedgerId;

  static const _dayShort = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

  static String _dateStr(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<_ChartBar> _buildBars(FinanceProvider fin, String? ledgerFilter) {
    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day);
    final bars = <_ChartBar>[];
    for (var i = _chartRangeDays - 1; i >= 0; i--) {
      final d = base.subtract(Duration(days: i));
      final ds = _dateStr(d);
      var net = 0.0;
      for (final t in fin.transactions) {
        if (t.date != ds) continue;
        if (ledgerFilter != null && t.ledgerId != ledgerFilter) continue;
        net += t.type == 'income' ? t.amount : -t.amount;
      }
      final idxFromOldest = _chartRangeDays - 1 - i;
      final label = _bottomLabel(d, idxFromOldest);
      bars.add(_ChartBar(label: label, net: net));
    }
    return bars;
  }

  String _bottomLabel(DateTime d, int idxFromOldest) {
    if (_chartRangeDays <= 7) {
      final labelIdx = d.weekday == DateTime.sunday ? 0 : d.weekday;
      return _dayShort[labelIdx];
    }
    if (_chartRangeDays <= 14) {
      return '${d.day}/${d.month}';
    }
    final last = _chartRangeDays - 1;
    if (idxFromOldest % 5 == 0 || idxFromOldest == last) return '${d.day}';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final fin = context.watch<FinanceProvider>();
    if (_chartLedgerId != null && !fin.ledgers.any((l) => l.id == _chartLedgerId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _chartLedgerId = null);
      });
    }
    final chartLedgerFilter =
        _chartLedgerId != null && fin.ledgers.any((l) => l.id == _chartLedgerId) ? _chartLedgerId : null;

    final bars = _buildBars(fin, chartLedgerFilter);
    final maxAbs = bars.fold<double>(0, (m, e) => math.max(m, e.net.abs()));
    final chartMaxY = maxAbs < 1 ? 100.0 : maxAbs * 1.15;
    final rodWidth = _chartRangeDays <= 7 ? 14.0 : (_chartRangeDays <= 14 ? 7.0 : 4.0);

    final recent = [...fin.transactions]..sort((a, b) => b.date.compareTo(a.date));
    final recent5 = recent.take(5).toList();

    return RefreshIndicator(
      onRefresh: () => context.read<FinanceProvider>().reloadFromDisk(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.card,
                  border: Border.all(color: AppColors.borderSoft.withValues(alpha: 0.85)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.inkPrimary.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: UangkyLogo(variant: UangkyLogoVariant.transparent, size: 44),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Beranda',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: AppColors.inkPrimary,
                          ),
                    ),
                    Text(
                      'Ringkasan keuanganmu',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.inkMuted,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Pengaturan',
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.inkPrimary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total saldo',
                    style: TextStyle(
                      color: AppColors.peach.withValues(alpha: 0.88),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatIdr(fin.totalBalance),
                    style: const TextStyle(
                      color: AppColors.peach,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: widget.onAddTransaction,
                      icon: const Icon(Icons.add, color: AppColors.inkPrimary),
                      label: const Text(
                        'Tambah catatan',
                        style: TextStyle(
                          color: AppColors.inkPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.peach,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Buku',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkSecondary,
                ),
          ),
          ...fin.ledgers.map((ledger) {
            final bal = fin.ledgerBalance(ledger.id);
            final tint = parseHexColor(ledger.color, opacity: 0.28);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: AppColors.surfaceGlass,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => widget.onOpenLedgerInBooks(ledger.id),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: tint,
                          child: Text(ledger.icon, style: const TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ledger.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                ledger.type,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatIdr(bal),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 14),
          Text(
            'Arus kas',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkSecondary,
                ),
          ),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 7, label: Text('7 h')),
              ButtonSegment(value: 14, label: Text('14 h')),
              ButtonSegment(value: 30, label: Text('30 h')),
            ],
            selected: {_chartRangeDays},
            onSelectionChanged: (s) => setState(() => _chartRangeDays = s.first),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String?>(
            value: chartLedgerFilter,
            decoration: const InputDecoration(
              labelText: 'Filter buku',
              isDense: true,
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Semua buku'),
              ),
              for (final l in fin.ledgers)
                DropdownMenuItem<String?>(
                  value: l.id,
                  child: Text('${l.icon} ${l.name}', overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (v) => setState(() => _chartLedgerId = v),
          ),
          const SizedBox(height: 6),
          RepaintBoundary(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 12, 6, 6),
                child: SizedBox(
                  height: 188,
                  child: BarChart(
                    BarChartData(
                      maxY: chartMaxY,
                      minY: 0,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final i = group.x.toInt();
                          if (i < 0 || i >= bars.length) return null;
                          final net = bars[i].net;
                          return BarTooltipItem(
                            '${bars[i].label.isEmpty ? 'Hari ${i + 1}' : bars[i].label}\n${formatIdr(net)}',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, m) {
                            final i = v.toInt();
                            if (i < 0 || i >= bars.length) return const SizedBox.shrink();
                            final t = bars[i].label;
                            if (t.isEmpty) return const SizedBox(height: 18);
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                t,
                                style: const TextStyle(fontSize: 10, color: Colors.black87),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (v, m) => Text(
                            v >= 1000000
                                ? '${(v / 1000000).toStringAsFixed(1)}jt'
                                : v >= 1000
                                    ? '${(v / 1000).toStringAsFixed(0)}k'
                                    : v.toInt().toString(),
                            style: const TextStyle(fontSize: 10, color: Colors.black54),
                          ),
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    barGroups: [
                      for (var i = 0; i < bars.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: bars[i].net.abs(),
                              width: rodWidth,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              color: bars[i].net >= 0 ? AppColors.chartGreen : AppColors.chartRed,
                            ),
                          ],
                        ),
                    ],
                    ),
                  duration: Duration.zero,
                  curve: Curves.linear,
                ),
              ),
            ),
          ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.trending_up, size: 16, color: AppColors.incomeGreen),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Net harian (hijau positif, merah negatif) — sentuh batang untuk nominal',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: AppColors.inkMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Transaksi terakhir',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkSecondary,
                      ),
                ),
              ),
              TextButton(
                onPressed: widget.onOpenReportsTab,
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...recent5.map((t) {
            final ledger = fin.ledgerById(t.ledgerId);
            final pos = t.type == 'income';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  onTap: () => widget.onEditTransaction(t),
                  title: Text(t.category, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${ledger?.name ?? '-'} • ${t.date}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${pos ? '+' : '-'}${formatIdr(t.amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: pos ? AppColors.incomeGreen : AppColors.expenseRed,
                          fontSize: 13,
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ketuk baris untuk ubah. Jadwal & pengingat: menu pengaturan (ikon roda).',
                      style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartBar {
  _ChartBar({required this.label, required this.net});
  final String label;
  final double net;
}
