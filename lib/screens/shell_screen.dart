// Kerangka app: [NavigationBar] + isi tab. Hanya tab aktif yang di-build (ringan di memori/CPU).
// Jadwal dicek di frame pertama dan saat app resumed — tanpa timer periodik.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../providers/finance_provider.dart';
import 'add_transaction_screen.dart';
import 'dashboard_screen.dart';
import 'ledger_detail_screen.dart';
import 'ledgers_screen.dart';
import 'reports_screen.dart';
import 'scheduling_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/web_mobile_download_banner.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> with WidgetsBindingObserver {
  int _tab = 0;
  String? _ledgerDetailId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FinanceProvider>().checkDueSchedules();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<FinanceProvider>().checkDueSchedules();
    }
  }

  void _openLedger(String id) => setState(() => _ledgerDetailId = id);
  void _closeLedger() => setState(() => _ledgerDetailId = null);

  void _onDestination(int index) {
    setState(() {
      _tab = index;
      if (index != 1) _ledgerDetailId = null;
    });
  }

  Future<void> _openAddTransaction({String? ledgerId, Transaction? existing}) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(
          preselectedLedgerId: ledgerId,
          existing: existing,
        ),
      ),
    );
  }

  Widget _buildActiveTab() {
    switch (_tab) {
      case 0:
        return DashboardScreen(
          onAddTransaction: () => _openAddTransaction(),
          onEditTransaction: (t) => _openAddTransaction(existing: t),
          onOpenLedgerInBooks: (id) {
            setState(() {
              _tab = 1;
              _ledgerDetailId = id;
            });
          },
          onOpenReportsTab: () => setState(() => _tab = 3),
        );
      case 1:
        if (_ledgerDetailId != null) {
          return LedgerDetailScreen(
            ledgerId: _ledgerDetailId!,
            onBack: _closeLedger,
            onEditTransaction: (t) => _openAddTransaction(existing: t),
          );
        }
        return LedgersScreen(onOpenLedger: _openLedger);
      case 2:
        return const SchedulingScreen();
      case 3:
        return const ReportsScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final showCatat = _tab == 0 || _tab == 1;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            const WebMobileDownloadBanner(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.peach.withValues(alpha: 0.2),
                        scheme.surfaceContainerHighest.withValues(alpha: 0.28),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: RepaintBoundary(child: _buildActiveTab()),
                  ),
                ),
              ),
            ),
            if (showCatat)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _openAddTransaction(ledgerId: _ledgerDetailId),
                    icon: const Icon(Icons.add, size: 22),
                    label: const Text('Catat transaksi'),
                  ),
                ),
              ),
            NavigationBar(
              height: 60,
              selectedIndex: _tab,
              onDestinationSelected: _onDestination,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Beranda',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book),
                  label: 'Buku',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month),
                  label: 'Jadwal',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart),
                  label: 'Laporan',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
