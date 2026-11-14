import 'package:breakbot/shared/models/user.dart';

class AuthRequestDto {
  final String email;
  final String password;

  AuthRequestDto({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequestDto {
  final String name;
  final String email;
  final String password;

  RegisterRequestDto({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
      };
}

class AuthResponseDto {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String name;
  final String email;

  AuthResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.name,
    required this.email,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      accessToken: json['access_token'] ?? json['access'] ?? '',
      refreshToken: json['refresh_token'] ?? json['refresh'] ?? '',
      userId: json['user_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class UserDto {
  final String id;
  final String name;
  final String email;
  final bool fingerprintEnabled;
  final String language;

  UserDto({
    required this.id,
    required this.name,
    required this.email,
    this.fingerprintEnabled = false,
    this.language = 'ar',
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      fingerprintEnabled: json['fingerprint_enabled'] ?? false,
      language: json['language'] ?? 'ar',
    );
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      fingerprintEnabled: fingerprintEnabled,
      language: language,
    );
  }
}