class Notification {
  final String id;
  final String title;
  final String message;
  final String type; // info, warning, error, success
  final bool isRead;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.timestamp,
    this.latitude,
    this.longitude,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      isRead: json['isRead'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'type': type,
    'isRead': isRead,
    'timestamp': timestamp.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
  };
}
