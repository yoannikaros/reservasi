class Setting {
  final int? id;
  final String? businessName;
  final String? noteHeader;
  final String? noteFooter;
  final String? updatedAt;

  Setting({
    this.id,
    this.businessName,
    this.noteHeader,
    this.noteFooter,
    this.updatedAt,
  });

  factory Setting.fromMap(Map<String, dynamic> map) {
    return Setting(
      id: map['id'],
      businessName: map['business_name'],
      noteHeader: map['note_header'],
      noteFooter: map['note_footer'],
      updatedAt: map['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_name': businessName,
      'note_header': noteHeader,
      'note_footer': noteFooter,
      'updated_at': updatedAt,
    };
  }

  Setting copyWith({
    int? id,
    String? businessName,
    String? noteHeader,
    String? noteFooter,
    String? updatedAt,
  }) {
    return Setting(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      noteHeader: noteHeader ?? this.noteHeader,
      noteFooter: noteFooter ?? this.noteFooter,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
