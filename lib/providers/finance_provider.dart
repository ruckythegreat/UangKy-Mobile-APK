// State global: buku, transaksi, jadwal. Setiap mutasi menyimpan ke [StorageService].
// Jadwal jatuh tempo di [_checkSchedules], dipanggil saat app siap / resume (tanpa timer periodik).
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/ledger.dart';
import '../models/schedule.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

List<Ledger> _seedLedgers() => [
      Ledger(
        id: '1',
        name: 'Dompet Pribadi',
        type: 'Personal',
        icon: '💰',
        color: '#FF3B30',
      ),
      Ledger(
        id: '2',
        name: 'Kas Kelas',
        type: 'Bendahara',
        icon: '📚',
        color: '#FF8A80',
      ),
      Ledger(
        id: '3',
        name: 'Warung Jujur',
        type: 'Warung',
        icon: '🏪',
        color: '#FFCC99',
      ),
    ];

List<Transaction> _seedTransactions() => [
      Transaction(
        id: 't1',
        ledgerId: '1',
        amount: 500000,
        type: 'income',
        category: 'Gaji',
        method: 'transfer',
        date: '2026-05-01',
        notes: 'Gaji bulanan',
      ),
      Transaction(
        id: 't2',
        ledgerId: '1',
        amount: 50000,
        type: 'expense',
        category: 'Makan',
        method: 'cash',
        date: '2026-05-02',
        notes: 'Makan siang',
      ),
      Transaction(
        id: 't3',
        ledgerId: '2',
        amount: 200000,
        type: 'income',
        category: 'Iuran',
        method: 'transfer',
        date: '2026-05-01',
        notes: 'Iuran siswa',
      ),
    ];

List<Schedule> _seedSchedules() => [
      Schedule(
        id: 's1',
        name: 'Gaji Bulanan',
        ledgerId: '1',
        amount: 500000,
        type: 'income',
        category: 'Gaji',
        interval: 'monthly',
        dayOfMonth: 25,
        isActive: true,
      ),
      Schedule(
        id: 's2',
        name: 'Tagihan Listrik',
        ledgerId: '1',
        amount: 150000,
        type: 'expense',
        category: 'Tagihan',
        interval: 'monthly',
        dayOfMonth: 1,
        isActive: true,
      ),
    ];

class FinanceProvider extends ChangeNotifier {
  FinanceProvider({StorageService? storage}) : _storage = storage ?? StorageService() {
    unawaited(_bootstrap());
  }

  final StorageService _storage;

  List<Ledger> _ledgers = [];
  List<Transaction> _transactions = [];
  List<Schedule> _schedules = [];

  bool _ready = false;
  bool get isReady => _ready;

  List<Ledger> get ledgers => List.unmodifiable(_ledgers);
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  List<Schedule> get schedules => List.unmodifiable(_schedules);

  /// Cari buku dari id (untuk UI; hindari loop berulang di widget).
  Ledger? ledgerById(String id) {
    for (final l in _ledgers) {
      if (l.id == id) return l;
    }
    return null;
  }

  /// Load awal dari disk atau seed demo; setelah itu [isReady] dan panggil cek jadwal hari ini.
  Future<void> _bootstrap() async {
    try {
      final payload = await _storage.loadPayload();
      if (payload != null) {
        _ledgers = (payload['ledgers'] as List<dynamic>)
            .map((e) => Ledger.fromJson(e as Map<String, dynamic>))
            .toList();
        _transactions = (payload['transactions'] as List<dynamic>)
            .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList();
        _schedules = (payload['schedules'] as List<dynamic>)
            .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        _ledgers = _seedLedgers();
        _transactions = _seedTransactions();
        _schedules = _seedSchedules();
        await _persist();
      }
    } catch (_) {
      _ledgers = _seedLedgers();
      _transactions = _seedTransactions();
      _schedules = _seedSchedules();
    }
    _ready = true;
    _checkSchedules();
    notifyListeners();
  }

  Future<void> reloadFromDisk() async {
    final payload = await _storage.loadPayload();
    if (payload == null) return;
    _ledgers = (payload['ledgers'] as List<dynamic>)
        .map((e) => Ledger.fromJson(e as Map<String, dynamic>))
        .toList();
    _transactions = (payload['transactions'] as List<dynamic>)
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList();
    _schedules = (payload['schedules'] as List<dynamic>)
        .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  Future<void> _persist() => _storage.savePayload(
        ledgers: _ledgers,
        transactions: _transactions,
        schedules: _schedules,
      );

  double ledgerBalance(String ledgerId) {
    var sum = 0.0;
    for (final t in _transactions) {
      if (t.ledgerId != ledgerId) continue;
      sum += t.type == 'income' ? t.amount : -t.amount;
    }
    return sum;
  }

  double get totalBalance {
    var sum = 0.0;
    for (final l in _ledgers) {
      sum += ledgerBalance(l.id);
    }
    return sum;
  }

  /// Menambahkan transaksi otomatis untuk jadwal yang jatuh tempo hari ini (maks sekali per jadwal per hari via lastExecuted).
  void _checkSchedules() {
    final today = DateTime.now();
    final todayString =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final toAdd = <Transaction>[];
    var changed = false;

    final updated = _schedules.map((schedule) {
      if (!schedule.isActive) return schedule;
      if (schedule.lastExecuted == todayString) return schedule;

      var shouldExecute = false;
      if (schedule.interval == 'daily') {
        shouldExecute = true;
      } else if (schedule.interval == 'weekly' &&
          schedule.dayOfWeek != null) {
        // Sama seperti Date.getDay() di JS: Minggu=0 … Sabtu=6 (Dart: Sen=1 … Min=7).
        final jsDay = today.weekday == DateTime.sunday ? 0 : today.weekday;
        shouldExecute = jsDay == schedule.dayOfWeek;
      } else if (schedule.interval == 'monthly' &&
          schedule.dayOfMonth != null) {
        shouldExecute = today.day == schedule.dayOfMonth;
      }

      if (shouldExecute) {
        changed = true;
        toAdd.add(
          Transaction(
            id: '${DateTime.now().millisecondsSinceEpoch}_${schedule.id}',
            ledgerId: schedule.ledgerId,
            amount: schedule.amount,
            type: schedule.type,
            category: schedule.category,
            method: 'transfer',
            date: todayString,
            notes: 'Auto-Generated: ${schedule.name}',
            isAutoGenerated: true,
          ),
        );
        return schedule.copyWith(lastExecuted: todayString);
      }
      return schedule;
    }).toList();

    if (changed) {
      _schedules = updated;
      _transactions = [..._transactions, ...toAdd];
      notifyListeners();
      unawaited(_persist());
    }
  }

  Future<void> addLedger(Ledger ledger) async {
    _ledgers = [..._ledgers, ledger];
    notifyListeners();
    await _persist();
  }

  Future<void> addTransaction(Transaction t) async {
    _transactions = [..._transactions, t];
    notifyListeners();
    await _persist();
  }

  Future<void> updateTransaction(Transaction updated) async {
    _transactions = _transactions.map((t) => t.id == updated.id ? updated : t).toList();
    notifyListeners();
    await _persist();
  }

  Future<void> deleteTransaction(String id) async {
    _transactions = _transactions.where((t) => t.id != id).toList();
    notifyListeners();
    await _persist();
  }

  Future<void> addSchedule(Schedule s) async {
    _schedules = [..._schedules, s];
    notifyListeners();
    await _persist();
  }

  Future<void> updateSchedule(String id, Schedule Function(Schedule) fn) async {
    _schedules = _schedules.map((s) => s.id == id ? fn(s) : s).toList();
    notifyListeners();
    await _persist();
  }

  Future<void> deleteSchedule(String id) async {
    _schedules = _schedules.where((s) => s.id != id).toList();
    notifyListeners();
    await _persist();
  }

  Future<void> replaceAll({
    required List<Ledger> ledgers,
    required List<Transaction> transactions,
    required List<Schedule> schedules,
  }) async {
    _ledgers = List.of(ledgers);
    _transactions = List.of(transactions);
    _schedules = List.of(schedules);
    notifyListeners();
    await _persist();
  }

  Future<void> resetToDemo() async {
    _ledgers = _seedLedgers();
    _transactions = _seedTransactions();
    _schedules = _seedSchedules();
    notifyListeners();
    await _persist();
  }

  Future<void> clearAll() async {
    _ledgers = [];
    _transactions = [];
    _schedules = [];
    notifyListeners();
    await _storage.clear();
  }

  /// Jalankan saat cold start / resume app — menggantikan polling timer agar hemat baterai & stabil di tes.
  void checkDueSchedules() => _checkSchedules();
}
