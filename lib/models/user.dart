class User {
  final int? id;
  final String username;
  final String password;
  final String role;
  final String? email;
  final String? createdAt;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.role,
    this.email,
    this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      role: map['role'],
      email: map['email'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role,
      'email': email,
      'created_at': createdAt,
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? password,
    String? role,
    String? email,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
