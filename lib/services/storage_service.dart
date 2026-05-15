// Satu blob JSON (buku + transaksi + jadwal) per kunci SharedPreferences — dipanggil dari [FinanceProvider].
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/ledger.dart';
import '../models/schedule.dart';
import '../models/transaction.dart';

const _kDataKey = 'uangky_finance_v1';

class StorageService {
  Future<Map<String, dynamic>?> loadPayload() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kDataKey);
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> savePayload({
    required List<Ledger> ledgers,
    required List<Transaction> transactions,
    required List<Schedule> schedules,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'ledgers': ledgers.map((e) => e.toJson()).toList(),
      'transactions': transactions.map((e) => e.toJson()).toList(),
      'schedules': schedules.map((e) => e.toJson()).toList(),
    };
    await prefs.setString(_kDataKey, jsonEncode(payload));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kDataKey);
  }
}
