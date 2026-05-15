class Schedule {
  Schedule({
    required this.id,
    required this.name,
    required this.ledgerId,
    required this.amount,
    required this.type,
    required this.category,
    required this.interval,
    this.dayOfWeek,
    this.dayOfMonth,
    this.lastExecuted,
    required this.isActive,
  });

  final String id;
  final String name;
  final String ledgerId;
  final double amount;
  final String type;
  final String category;
  final String interval;
  final int? dayOfWeek;
  final int? dayOfMonth;
  final String? lastExecuted;
  final bool isActive;

  Schedule copyWith({
    String? id,
    String? name,
    String? ledgerId,
    double? amount,
    String? type,
    String? category,
    String? interval,
    int? dayOfWeek,
    int? dayOfMonth,
    String? lastExecuted,
    bool? isActive,
  }) {
    return Schedule(
      id: id ?? this.id,
      name: name ?? this.name,
      ledgerId: ledgerId ?? this.ledgerId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      interval: interval ?? this.interval,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      lastExecuted: lastExecuted ?? this.lastExecuted,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'ledgerId': ledgerId,
        'amount': amount,
        'type': type,
        'category': category,
        'interval': interval,
        'dayOfWeek': dayOfWeek,
        'dayOfMonth': dayOfMonth,
        'lastExecuted': lastExecuted,
        'isActive': isActive,
      };

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as String,
      name: json['name'] as String,
      ledgerId: json['ledgerId'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      category: json['category'] as String,
      interval: json['interval'] as String,
      dayOfWeek: json['dayOfWeek'] as int?,
      dayOfMonth: json['dayOfMonth'] as int?,
      lastExecuted: json['lastExecuted'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
