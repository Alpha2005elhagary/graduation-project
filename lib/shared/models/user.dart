import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final bool fingerprintEnabled;
  final String language;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.fingerprintEnabled = false,
    this.language = 'ar',
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, email, fingerprintEnabled, language, createdAt];

  User copyWith({
    String? id,
    String? name,
    String? email,
    bool? fingerprintEnabled,
    String? language,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      fingerprintEnabled: fingerprintEnabled ?? this.fingerprintEnabled,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'fingerprintEnabled': fingerprintEnabled,
      'language': language,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      fingerprintEnabled: json['fingerprintEnabled'] ?? false,
      language: json['language'] ?? 'ar',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
