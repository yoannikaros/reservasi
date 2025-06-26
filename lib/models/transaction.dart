class Transaction {
  final int? id;
  final String type;
  final String? category;
  final double amount;
  final String? description;
  final String transactionDate;
  final String? createdAt;

  Transaction({
    this.id,
    required this.type,
    this.category,
    required this.amount,
    this.description,
    required this.transactionDate,
    this.createdAt,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      type: map['type'],
      category: map['category'],
      amount: map['amount'],
      description: map['description'],
      transactionDate: map['transaction_date'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'amount': amount,
      'description': description,
      'transaction_date': transactionDate,
      'created_at': createdAt,
    };
  }

  Transaction copyWith({
    int? id,
    String? type,
    String? category,
    double? amount,
    String? description,
    String? transactionDate,
    String? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
