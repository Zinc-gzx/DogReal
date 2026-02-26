class Challenge {
  final String id;
  final DateTime date;
  final String theme;
  final String icon;
  final String description;
  final String notificationTime;
  final bool notificationSent;
  final DateTime createdAt;
  final DateTime updatedAt;

  Challenge({
    required this.id,
    required this.date,
    required this.theme,
    required this.icon,
    required this.description,
    required this.notificationTime,
    required this.notificationSent,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['_id'] ?? '',
      date: DateTime.parse(json['date']),
      theme: json['theme'] ?? '',
      icon: json['icon'] ?? '🎯',
      description: json['description'] ?? '',
      notificationTime: json['notificationTime'] ?? '12:00',
      notificationSent: json['notificationSent'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'date': date.toIso8601String(),
      'theme': theme,
      'icon': icon,
      'description': description,
      'notificationTime': notificationTime,
      'notificationSent': notificationSent,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
