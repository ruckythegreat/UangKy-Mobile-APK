import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/schedule.dart';
import '../providers/finance_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_format.dart';
import '../widgets/empty_hint.dart';

/// Tab Jadwal: transaksi berulang. Eksekusi ke buku saat app dibuka/dilanjutkan ([FinanceProvider.checkDueSchedules]).
const _incomeCategories = ['Gaji', 'Bonus', 'Iuran', 'Penjualan', 'Lainnya'];
const _expenseCategories = [
  'Makan',
  'Transport',
  'Tagihan',
  'Stok Barang',
  'Iuran',
  'Lainnya',
];

class SchedulingScreen extends StatefulWidget {
  const SchedulingScreen({super.key});

  @override
  State<SchedulingScreen> createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends State<SchedulingScreen> {
  bool _showForm = false;

  final _nameCtrl = TextEditingController();
  late String _ledgerId;
  final _amountCtrl = TextEditingController();
  String _type = 'expense';
  String _category = '';
  String _interval = 'monthly';
  int _dayOfWeek = 1;
  int _dayOfMonth = 1;
  String? _nameError;
  String? _amountError;
  String? _categoryError;

  @override
  void initState() {
    super.initState();
    final fin = context.read<FinanceProvider>();
    _ledgerId = fin.ledgers.isNotEmpty ? fin.ledgers.first.id : '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  List<String> get _categories =>
      _type == 'income' ? _incomeCategories : _expenseCategories;

  String _intervalLabel(Schedule s) {
    if (s.interval == 'daily') return 'Setiap hari';
    if (s.interval == 'weekly') {
      const days = [
        'Minggu',
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
      ];
      final idx = s.dayOfWeek ?? 1;
      return 'Setiap ${days[idx.clamp(0, 6)]}';
    }
    return 'Setiap tanggal ${s.dayOfMonth ?? 1}';
  }

  Future<void> _save() async {
    final fin = context.read<FinanceProvider>();
    final name = _nameCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;
    final nameError = name.isEmpty ? 'Masukkan nama jadwal' : null;
    final amountError = amount <= 0 ? 'Masukkan nominal lebih dari 0' : null;
    final categoryError = _category.isEmpty ? 'Pilih kategori' : null;
    setState(() {
      _nameError = nameError;
      _amountError = amountError;
      _categoryError = categoryError;
    });
    if (nameError != null || amountError != null || categoryError != null) {
      return;
    }
    final s = Schedule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      ledgerId: _ledgerId,
      amount: amount,
      type: _type,
      category: _category,
      interval: _interval,
      dayOfWeek: _interval == 'weekly' ? _dayOfWeek : null,
      dayOfMonth: _interval == 'monthly' ? _dayOfMonth : null,
      isActive: true,
    );
    await fin.addSchedule(s);
    setState(() {
      _showForm = false;
      _nameCtrl.clear();
      _amountCtrl.clear();
      _category = '';
      _type = 'expense';
      _interval = 'monthly';
      _dayOfWeek = 1;
      _dayOfMonth = 1;
      _ledgerId = fin.ledgers.isNotEmpty ? fin.ledgers.first.id : '';
      _nameError = null;
      _amountError = null;
      _categoryError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fin = context.watch<FinanceProvider>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Text(
          'Jadwal otomatis',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.inkPrimary,
          ),
        ),
        Text(
          'Harian, mingguan, atau bulanan — dijalankan saat app aktif',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: 16),
        if (!_showForm)
          FilledButton.icon(
            onPressed: () => setState(() => _showForm = true),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Jadwal Baru'),
          ),
        if (_showForm) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Jadwal Baru',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _showForm = false),
                        child: const Text('Batal'),
                      ),
                    ],
                  ),
                  TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama jadwal',
                      errorText: _nameError,
                    ),
                    onChanged: (_) {
                      if (_nameError != null) setState(() => _nameError = null);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _ledgerId.isEmpty ? null : _ledgerId,
                    items: [
                      for (final l in fin.ledgers)
                        DropdownMenuItem(
                          value: l.id,
                          child: Text('${l.icon} ${l.name}'),
                        ),
                    ],
                    onChanged: (v) => setState(() => _ledgerId = v ?? ''),
                    decoration: const InputDecoration(labelText: 'Buku'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniType(
                          label: 'Masuk',
                          selected: _type == 'income',
                          color: AppColors.incomeGreen,
                          onTap: () => setState(() {
                            _type = 'income';
                            _category = '';
                          }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MiniType(
                          label: 'Keluar',
                          selected: _type == 'expense',
                          color: AppColors.expenseRed,
                          onTap: () => setState(() {
                            _type = 'expense';
                            _category = '';
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Nominal',
                      errorText: _amountError,
                    ),
                    onChanged: (_) {
                      if (_amountError != null) {
                        setState(() => _amountError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _category.isEmpty ? null : _category,
                    hint: const Text('Kategori'),
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      errorText: _categoryError,
                    ),
                    items: [
                      for (final c in _categories)
                        DropdownMenuItem(value: c, child: Text(c)),
                    ],
                    onChanged: (v) => setState(() {
                      _category = v ?? '';
                      _categoryError = null;
                    }),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _interval,
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('Harian')),
                      DropdownMenuItem(
                        value: 'weekly',
                        child: Text('Mingguan'),
                      ),
                      DropdownMenuItem(
                        value: 'monthly',
                        child: Text('Bulanan'),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => _interval = v ?? 'monthly'),
                    decoration: const InputDecoration(labelText: 'Interval'),
                  ),
                  if (_interval == 'weekly') ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _dayOfWeek,
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Senin')),
                        DropdownMenuItem(value: 2, child: Text('Selasa')),
                        DropdownMenuItem(value: 3, child: Text('Rabu')),
                        DropdownMenuItem(value: 4, child: Text('Kamis')),
                        DropdownMenuItem(value: 5, child: Text('Jumat')),
                        DropdownMenuItem(value: 6, child: Text('Sabtu')),
                        DropdownMenuItem(value: 0, child: Text('Minggu')),
                      ],
                      onChanged: (v) => setState(() => _dayOfWeek = v ?? 1),
                      decoration: const InputDecoration(
                        labelText: 'Hari (Minggu=0 … Sabtu=6)',
                      ),
                    ),
                  ],
                  if (_interval == 'monthly') ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _dayOfMonth.clamp(1, 31),
                      decoration: const InputDecoration(
                        labelText: 'Tanggal tiap bulan',
                      ),
                      items: [
                        for (var i = 1; i <= 31; i++)
                          DropdownMenuItem(value: i, child: Text('$i')),
                      ],
                      onChanged: (v) => setState(() => _dayOfMonth = v ?? 1),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _save,
                    child: const Text('Simpan Jadwal'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          'Daftar jadwal',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.inkSecondary,
          ),
        ),
        const SizedBox(height: 8),
        if (fin.schedules.isEmpty)
          Card(
            child: EmptyHint(
              text:
                  'Belum ada jadwal otomatis. Tambahkan tagihan atau pemasukan berulang agar tidak perlu dicatat manual.',
              action: 'Tambah jadwal',
              onAction: () => setState(() => _showForm = true),
            ),
          )
        else
          ...fin.schedules.map((schedule) {
            final ledger = fin.ledgerById(schedule.ledgerId);
            final pos = schedule.type == 'income';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  schedule.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  ledger?.name ?? '-',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.inkMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${pos ? '+' : '-'}${formatIdr(schedule.amount)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: pos
                                  ? AppColors.incomeGreen
                                  : AppColors.expenseRed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_intervalLabel(schedule)} • ${schedule.category}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                context.read<FinanceProvider>().updateSchedule(
                                  schedule.id,
                                  (s) => s.copyWith(isActive: !s.isActive),
                                );
                              },
                              icon: Icon(
                                schedule.isActive
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                size: 18,
                              ),
                              label: Text(
                                schedule.isActive ? 'Jeda' : 'Aktifkan',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Tooltip(
                            message: 'Hapus jadwal',
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.expenseRed,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                              ),
                              onPressed: () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Hapus jadwal?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Batal'),
                                      ),
                                      FilledButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  ),
                                );
                                if (ok == true && context.mounted) {
                                  await context
                                      .read<FinanceProvider>()
                                      .deleteSchedule(schedule.id);
                                }
                              },
                              child: const Icon(
                                Icons.delete_outline,
                                color: AppColors.onInk,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (schedule.lastExecuted != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Terakhir dijalankan: ${schedule.lastExecuted}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ),
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
            child: Text(
              'Jadwal dijalankan saat aplikasi dibuka atau kembali dari latar. '
              'Untuk tagihan sangat ketat, buka aplikasi sekali sehari atau gunakan pengingat sistem.',
              style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniType extends StatelessWidget {
  const _MiniType({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color : AppColors.surfaceGlass,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.onInk : AppColors.inkPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
