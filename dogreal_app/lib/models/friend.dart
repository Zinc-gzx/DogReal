class Friend {
  final String id;
  final String username;
  final String email;
  final DateTime? since;

  Friend({
    required this.id,
    required this.username,
    required this.email,
    this.since,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] ?? json['_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      since: json['since'] != null ? DateTime.parse(json['since']) : null,
    );
  }
}

class FriendRequest {
  final String id;
  final String requesterId;
  final String requesterUsername;
  final String requesterEmail;
  final DateTime createdAt;
  final String status;

  FriendRequest({
    required this.id,
    required this.requesterId,
    required this.requesterUsername,
    required this.requesterEmail,
    required this.createdAt,
    required this.status,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    final requester = json['requester'] as Map<String, dynamic>?;
    
    return FriendRequest(
      id: json['_id'] ?? '',
      requesterId: requester?['_id'] ?? '',
      requesterUsername: requester?['username'] ?? '',
      requesterEmail: requester?['email'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'] ?? 'pending',
    );
  }
}

class UserSearchResult {
  final String id;
  final String username;
  final String email;
  final String friendshipStatus; // none, pending, accepted, rejected
  final bool isRequester; // 是否是我发起的请求

  UserSearchResult({
    required this.id,
    required this.username,
    required this.email,
    required this.friendshipStatus,
    required this.isRequester,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      friendshipStatus: json['friendshipStatus'] ?? 'none',
      isRequester: json['isRequester'] ?? false,
    );
  }
}
