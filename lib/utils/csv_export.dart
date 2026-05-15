import '../models/ledger.dart';
import '../models/transaction.dart';

String buildCsv({
  required List<Transaction> transactions,
  required List<Ledger> ledgers,
}) {
  final header = 'Tanggal,Buku,Kategori,Jenis,Metode,Nominal,Catatan';
  final rows = transactions.map((t) {
    Ledger? ledger;
    for (final l in ledgers) {
      if (l.id == t.ledgerId) {
        ledger = l;
        break;
      }
    }
    final book = ledger?.name ?? '';
    final type = t.type == 'income' ? 'Masuk' : 'Keluar';
    final method = t.method == 'cash' ? 'Tunai' : 'Transfer';
    final notes = t.notes.replaceAll('"', '""');
    return '${t.date},$book,${t.category},$type,$method,${t.amount},"$notes"';
  });
  return [header, ...rows].join('\n');
}
