class Item {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final double rating;
  final int views;
  final DateTime createdAt;
  final String category;

  Item({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.rating,
    required this.views,
    required this.createdAt,
    required this.category,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      rating: (json['rating'] as num).toDouble(),
      views: json['views'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'rating': rating,
        'views': views,
        'createdAt': createdAt.toIso8601String(),
        'category': category,
      };

  Item copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    double? rating,
    int? views,
    DateTime? createdAt,
    String? category,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
    );
  }
}
