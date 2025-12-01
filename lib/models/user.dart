class User {
  final String id;
  final String name;
  final String email;
  final String? profilePictureUrl;
  final String? bio;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePictureUrl,
    this.bio,
    required this.createdAt,
  });

  // JSON serialization
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      bio: json['bio'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'profilePictureUrl': profilePictureUrl,
        'bio': bio,
        'createdAt': createdAt.toIso8601String(),
      };

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePictureUrl,
    String? bio,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
