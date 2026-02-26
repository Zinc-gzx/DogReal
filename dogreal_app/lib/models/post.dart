class PostImage {
  final String url;
  final String type; // 'front' or 'back'

  PostImage({
    required this.url,
    required this.type,
  });

  factory PostImage.fromJson(Map<String, dynamic> json) {
    return PostImage(
      url: json['url'] ?? '',
      type: json['type'] ?? 'front',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'type': type,
    };
  }
}

class Comment {
  final String id;
  final String userId;
  final String username;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.username,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'] ?? '',
      userId: json['user'] is String ? json['user'] : (json['user']?['_id'] ?? ''),
      username: json['user'] is String ? '' : (json['user']?['username'] ?? ''),
      text: json['text'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Post {
  final String id;
  final String userId;
  final String username;
  final String petId;
  final String petName;
  final String petBreed;
  final String petAvatar;
  final int petAge;
  final List<PostImage> images;
  final String caption;
  final String location;
  final List<String> likes;
  final int likesCount;
  final List<Comment> comments;
  final int commentsCount;
  final bool isLate;
  final DateTime postedAt;
  final DateTime createdAt;
  final bool isActive;

  Post({
    required this.id,
    required this.userId,
    required this.username,
    required this.petId,
    required this.petName,
    required this.petBreed,
    required this.petAvatar,
    required this.petAge,
    required this.images,
    required this.caption,
    required this.location,
    required this.likes,
    required this.likesCount,
    required this.comments,
    required this.commentsCount,
    required this.isLate,
    required this.postedAt,
    required this.createdAt,
    required this.isActive,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    // 处理用户信息
    final user = json['user'];
    final userId = user is String ? user : (user?['_id'] ?? '');
    final username = user is String ? '' : (user?['username'] ?? '');

    // 处理宠物信息
    final pet = json['pet'];
    final petId = pet is String ? pet : (pet?['_id'] ?? '');
    final petName = pet is String ? '' : (pet?['name'] ?? '');
    final petBreed = pet is String ? '' : (pet?['breed'] ?? '');
    final petAvatar = pet is String ? '' : (pet?['avatar'] ?? '');
    final petAge = pet is String ? 0 : (pet?['age'] ?? 0);

    // 处理图片
    final imagesList = (json['images'] as List?)
        ?.map((img) => PostImage.fromJson(img))
        .toList() ?? [];

    // 处理点赞
    final likesList = (json['likes'] as List?)
        ?.map((like) => like.toString())
        .toList() ?? [];

    // 处理评论
    final commentsList = (json['comments'] as List?)
        ?.map((comment) => Comment.fromJson(comment))
        .toList() ?? [];

    return Post(
      id: json['_id'] ?? '',
      userId: userId,
      username: username,
      petId: petId,
      petName: petName,
      petBreed: petBreed,
      petAvatar: petAvatar,
      petAge: petAge,
      images: imagesList,
      caption: json['caption'] ?? '',
      location: json['location'] ?? '',
      likes: likesList,
      likesCount: json['likesCount'] ?? 0,
      comments: commentsList,
      commentsCount: json['commentsCount'] ?? 0,
      isLate: json['isLate'] ?? false,
      postedAt: DateTime.parse(json['postedAt'] ?? json['createdAt']),
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
    );
  }

  Post copyWith({
    int? likesCount,
    List<String>? likes,
    int? commentsCount,
    List<Comment>? comments,
  }) {
    return Post(
      id: id,
      userId: userId,
      username: username,
      petId: petId,
      petName: petName,
      petBreed: petBreed,
      petAvatar: petAvatar,
      petAge: petAge,
      images: images,
      caption: caption,
      location: location,
      likes: likes ?? this.likes,
      likesCount: likesCount ?? this.likesCount,
      comments: comments ?? this.comments,
      commentsCount: commentsCount ?? this.commentsCount,
      isLate: isLate,
      postedAt: postedAt,
      createdAt: createdAt,
      isActive: isActive,
    );
  }
}
