class Booking {
  final int? id;
  final int customerId;
  final int venueId;
  final String date;
  final String startTime;
  final String endTime;
  final double? totalPrice;
  final String status;
  final int isPaid;
  final String? notes;
  final String? createdAt;
  
  // Tambahan untuk tampilan
  final String? customerName;
  final String? venueName;

  Booking({
    this.id,
    required this.customerId,
    required this.venueId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.totalPrice,
    this.status = 'reserved',
    this.isPaid = 0,
    this.notes,
    this.createdAt,
    this.customerName,
    this.venueName,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      customerId: map['customer_id'],
      venueId: map['venue_id'],
      date: map['date'],
      startTime: map['start_time'],
      endTime: map['end_time'],
      totalPrice: map['total_price'],
      status: map['status'],
      isPaid: map['is_paid'],
      notes: map['notes'],
      createdAt: map['created_at'],
      customerName: map['customer_name'],
      venueName: map['venue_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'venue_id': venueId,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'total_price': totalPrice,
      'status': status,
      'is_paid': isPaid,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  Booking copyWith({
    int? id,
    int? customerId,
    int? venueId,
    String? date,
    String? startTime,
    String? endTime,
    double? totalPrice,
    String? status,
    int? isPaid,
    String? notes,
    String? createdAt,
    String? customerName,
    String? venueName,
  }) {
    return Booking(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      venueId: venueId ?? this.venueId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      isPaid: isPaid ?? this.isPaid,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      customerName: customerName ?? this.customerName,
      venueName: venueName ?? this.venueName,
    );
  }
}
