import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../providers/finance_provider.dart';
import '../theme/app_colors.dart';
import '../utils/color_parse.dart';
import '../utils/currency_format.dart';
import 'add_transaction_screen.dart';

/// Satu buku: saldo, ringkas masuk/keluar, daftar transaksi (builder untuk daftar panjang).
class LedgerDetailScreen extends StatelessWidget {
  const LedgerDetailScreen({
    super.key,
    required this.ledgerId,
    required this.onBack,
    required this.onEditTransaction,
  });

  final String ledgerId;
  final VoidCallback onBack;
  final void Function(Transaction t) onEditTransaction;

  @override
  Widget build(BuildContext context) {
    final fin = context.watch<FinanceProvider>();
    final ledger = fin.ledgerById(ledgerId);
    if (ledger == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Buku tidak ditemukan'),
              const SizedBox(height: 12),
              FilledButton(onPressed: onBack, child: const Text('Kembali')),
            ],
          ),
        ),
      );
    }

    final txs = fin.transactions.where((t) => t.ledgerId == ledgerId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final balance = fin.ledgerBalance(ledgerId);
    var income = 0.0;
    var expense = 0.0;
    for (final t in txs) {
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    final tint = parseHexColor(ledger.color, opacity: 0.28);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: tint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(ledger.icon, style: const TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ledger.name,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                          ),
                          Text(
                            ledger.type,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF78716C)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1917),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saldo',
                          style: TextStyle(color: AppColors.peach.withValues(alpha: 0.88), fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatIdr(balance),
                          style: const TextStyle(
                            color: AppColors.peach,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _MiniStat(
                                label: 'Masuk',
                                value: formatIdr(income),
                                icon: Icons.trending_up,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MiniStat(
                                label: 'Keluar',
                                value: formatIdr(expense),
                                icon: Icons.trending_down,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) => AddTransactionScreen(preselectedLedgerId: ledgerId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Tambah di sini', style: TextStyle(fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1C1917),
                      side: const BorderSide(color: AppColors.borderSoft),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Riwayat',
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
        if (txs.isEmpty)
          SliverToBoxAdapter(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Belum ada transaksi',
                    style: TextStyle(color: Colors.black.withValues(alpha: 0.55)),
                  ),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 28),
            sliver: SliverList.separated(
              itemCount: txs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final transaction = txs[index];
                final pos = transaction.type == 'income';
                return Card(
                  child: ListTile(
                    onTap: () => onEditTransaction(transaction),
                    title: Text(
                      transaction.category,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.method == 'cash' ? 'Tunai' : 'Transfer',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF78716C)),
                        ),
                        Text(
                          transaction.date,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF78716C)),
                        ),
                        if (transaction.notes.isNotEmpty)
                          Text(
                            transaction.notes,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF57534E),
                            ),
                          ),
                        if (transaction.isAutoGenerated)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Otomatis',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${pos ? '+' : '-'}${formatIdr(transaction.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: pos ? AppColors.incomeGreen : AppColors.expenseRed,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Hapus',
                          icon: const Icon(Icons.delete_outline, size: 22),
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Hapus transaksi?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                                  FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
                                ],
                              ),
                            );
                            if (ok == true && context.mounted) {
                              await context.read<FinanceProvider>().deleteTransaction(transaction.id);
                            }
                          },
                        ),
                      ],
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

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.peach.withValues(alpha: 0.9)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: AppColors.peach.withValues(alpha: 0.85)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.peach,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
