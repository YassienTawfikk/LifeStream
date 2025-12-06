import 'dart:convert';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? profilePictureUrl;
  final String name;
  final double radius;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.profilePictureUrl,
    required this.name,
    this.radius = 20,
    this.onTap,
  });

  ImageProvider? _getImageProvider() {
    if (profilePictureUrl == null || profilePictureUrl!.isEmpty) {
      return null;
    }

    // Check if it's a legacy http URL
    if (profilePictureUrl!.startsWith('http')) {
      return NetworkImage(profilePictureUrl!);
    }

    // Assume Base64
    try {
      return MemoryImage(base64Decode(profilePictureUrl!));
    } catch (e) {
      debugPrint('Error decoding base64 image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _getImageProvider();

    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.blue.shade100,
        backgroundImage: imageProvider,
        child: imageProvider == null
            ? Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: radius,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              )
            : null,
      ),
    );
  }
}
