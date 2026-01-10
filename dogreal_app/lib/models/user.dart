class User {
  final String id;
  final String username;
  final String email;
  final String? avatar;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final User? user;
  final String? token;

  AuthResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: json['data']?['user'] != null
          ? User.fromJson(json['data']['user'])
          : null,
      token: json['data']?['token'],
    );
  }
}

class ApiError {
  final String message;
  final List<ValidationError>? errors;

  ApiError({
    required this.message,
    this.errors,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] ?? 'Unknown error',
      errors: json['errors'] != null
          ? (json['errors'] as List)
              .map((e) => ValidationError.fromJson(e))
              .toList()
          : null,
    );
  }
}

class ValidationError {
  final String field;
  final String message;

  ValidationError({
    required this.field,
    required this.message,
  });

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      field: json['field'] ?? json['path'] ?? '',
      message: json['message'] ?? json['msg'] ?? '',
    );
  }
}
