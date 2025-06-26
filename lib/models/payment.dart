class Payment {
  final int? id;
  final int bookingId;
  final double amount;
  final String? method;
  final String paymentDate;
  final String? note;
  
  // Tambahan untuk tampilan
  final String? customerName;
  final String? venueName;

  Payment({
    this.id,
    required this.bookingId,
    required this.amount,
    this.method,
    required this.paymentDate,
    this.note,
    this.customerName,
    this.venueName,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      bookingId: map['booking_id'],
      amount: map['amount'],
      method: map['method'],
      paymentDate: map['payment_date'],
      note: map['note'],
      customerName: map['customer_name'],
      venueName: map['venue_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'booking_id': bookingId,
      'amount': amount,
      'method': method,
      'payment_date': paymentDate,
      'note': note,
    };
  }

  Payment copyWith({
    int? id,
    int? bookingId,
    double? amount,
    String? method,
    String? paymentDate,
    String? note,
    String? customerName,
    String? venueName,
  }) {
    return Payment(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      paymentDate: paymentDate ?? this.paymentDate,
      note: note ?? this.note,
      customerName: customerName ?? this.customerName,
      venueName: venueName ?? this.venueName,
    );
  }
}
