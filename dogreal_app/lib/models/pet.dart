class Pet {
  final String id;
  final String name;
  final String breed;
  final DateTime birthday;
  final String gender;
  final String avatar;
  final String owner;
  final String bio;
  final double? weight;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int age;

  Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.birthday,
    required this.gender,
    required this.avatar,
    required this.owner,
    required this.bio,
    this.weight,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.age,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      breed: json['breed'] ?? '',
      birthday: DateTime.parse(json['birthday']),
      gender: json['gender'] ?? 'unknown',
      avatar: json['avatar'] ?? '',
      owner: json['owner'] is String 
          ? json['owner'] 
          : (json['owner']?['_id'] ?? ''),
      bio: json['bio'] ?? '',
      weight: json['weight']?.toDouble(),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      age: json['age'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'breed': breed,
      'birthday': birthday.toIso8601String(),
      'gender': gender,
      'avatar': avatar,
      'bio': bio,
      'weight': weight,
    };
  }

  Pet copyWith({
    String? id,
    String? name,
    String? breed,
    DateTime? birthday,
    String? gender,
    String? avatar,
    String? owner,
    String? bio,
    double? weight,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? age,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      avatar: avatar ?? this.avatar,
      owner: owner ?? this.owner,
      bio: bio ?? this.bio,
      weight: weight ?? this.weight,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      age: age ?? this.age,
    );
  }
}

class PetResponse {
  final bool success;
  final Pet? data;
  final String? message;

  PetResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory PetResponse.fromJson(Map<String, dynamic> json) {
    return PetResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? Pet.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}
