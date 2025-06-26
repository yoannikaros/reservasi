class Saving {
  final int? id;
  final String type;
  final double amount;
  final String? description;
  final String date;
  final String? createdAt;

  Saving({
    this.id,
    required this.type,
    required this.amount,
    this.description,
    required this.date,
    this.createdAt,
  });

  factory Saving.fromMap(Map<String, dynamic> map) {
    return Saving(
      id: map['id'],
      type: map['type'],
      amount: map['amount'],
      description: map['description'],
      date: map['date'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'description': description,
      'date': date,
      'created_at': createdAt,
    };
  }

  Saving copyWith({
    int? id,
    String? type,
    double? amount,
    String? description,
    String? date,
    String? createdAt,
  }) {
    return Saving(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
