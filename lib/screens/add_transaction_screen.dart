// Form tambah/ubah transaksi — simpan lewat [FinanceProvider.addTransaction] / [updateTransaction] / [deleteTransaction].
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../providers/finance_provider.dart';
import '../theme/app_colors.dart';

const _incomeCategories = ['Gaji', 'Bonus', 'Iuran', 'Penjualan', 'Lainnya'];
const _expenseCategories = ['Makan', 'Transport', 'Tagihan', 'Stok Barang', 'Iuran', 'Lainnya'];

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key, this.preselectedLedgerId, this.existing});

  /// Buku yang dipilih saat membuka dari tab Buku / FAB.
  final String? preselectedLedgerId;

  /// Jika diisi, layar jadi mode ubah (simpan = update, AppBar ada hapus).
  final Transaction? existing;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String _ledgerId = '';
  final _amountCtrl = TextEditingController();
  String _type = 'expense';
  String _category = '';
  String _method = 'cash';
  DateTime _date = DateTime.now();
  final _notesCtrl = TextEditingController();

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final fin = context.read<FinanceProvider>();
    final e = widget.existing;
    if (e != null) {
      _ledgerId = e.ledgerId;
      _amountCtrl.text = e.amount == e.amount.roundToDouble() ? e.amount.toInt().toString() : e.amount.toString();
      _type = e.type;
      _category = e.category;
      _method = e.method;
      _notesCtrl.text = e.notes;
      final parts = e.date.split('-');
      if (parts.length == 3) {
        _date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      }
    } else {
      _ledgerId = widget.preselectedLedgerId ??
          (fin.ledgers.isNotEmpty ? fin.ledgers.first.id : '');
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final fin = context.read<FinanceProvider>();
    if (fin.ledgers.isEmpty) return;
    if (!fin.ledgers.any((l) => l.id == _ledgerId)) {
      final next = fin.ledgers.first.id;
      if (next != _ledgerId) {
        setState(() => _ledgerId = next);
      }
    }
  }

  List<String> get _categories => _type == 'income' ? _incomeCategories : _expenseCategories;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;
    if (amount <= 0 || _category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi nominal dan kategori')),
      );
      return;
    }
    final ds =
        '${_date.year.toString().padLeft(4, '0')}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';
    final fin = context.read<FinanceProvider>();
    if (_isEdit) {
      final e = widget.existing!;
      await fin.updateTransaction(
        e.copyWith(
          ledgerId: _ledgerId,
          amount: amount,
          type: _type,
          category: _category,
          method: _method,
          date: ds,
          notes: _notesCtrl.text.trim(),
        ),
      );
    } else {
      await fin.addTransaction(
        Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          ledgerId: _ledgerId,
          amount: amount,
          type: _type,
          category: _category,
          method: _method,
          date: ds,
          notes: _notesCtrl.text.trim(),
        ),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final e = widget.existing;
    if (e == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus transaksi?'),
        content: const Text('Data ini akan hilang dari buku. Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<FinanceProvider>().deleteTransaction(e.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fin = context.watch<FinanceProvider>();
    if (fin.ledgers.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? 'Ubah transaksi' : 'Tambah transaksi', style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Belum ada buku. Buka tab Buku lalu tambah buku baru.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Ubah transaksi' : 'Tambah transaksi',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: 'Hapus',
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            'PILIH BUKU',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _ledgerId,
            items: [
              for (final l in fin.ledgers)
                DropdownMenuItem(
                  value: l.id,
                  child: Text('${l.icon} ${l.name}'),
                ),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _ledgerId = v);
            },
          ),
          const SizedBox(height: 16),
          Text(
            'JENIS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _TypeChip(
                  label: 'Masuk',
                  emoji: '💰',
                  selected: _type == 'income',
                  color: AppColors.incomeGreen,
                  onTap: () => setState(() {
                    _type = 'income';
                    _category = '';
                  }),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TypeChip(
                  label: 'Keluar',
                  emoji: '💸',
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
          const SizedBox(height: 16),
          Text(
            'NOMINAL',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: 'Masukkan nominal'),
          ),
          const SizedBox(height: 16),
          Text(
            'KATEGORI',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _category.isEmpty ? null : _category,
            hint: const Text('Pilih kategori'),
            items: [
              for (final c in _categories) DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: (v) => setState(() => _category = v ?? ''),
          ),
          const SizedBox(height: 16),
          Text(
            'METODE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MethodChip(
                  label: 'Tunai',
                  emoji: '💵',
                  selected: _method == 'cash',
                  onTap: () => setState(() => _method = 'cash'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MethodChip(
                  label: 'Transfer',
                  emoji: '💳',
                  selected: _method == 'transfer',
                  onTap: () => setState(() => _method = 'transfer'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'TANGGAL',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              '${_date.day}/${_date.month}/${_date.year}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDate,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: AppColors.surfaceGlass,
          ),
          const SizedBox(height: 16),
          Text(
            'CATATAN',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Opsional'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submit,
            child: Text(_isEdit ? 'Simpan perubahan' : 'Simpan transaksi'),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color : AppColors.surfaceGlass,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              '$emoji $label',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  const _MethodChip({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.black : AppColors.surfaceGlass,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              '$emoji $label',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.peach : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
