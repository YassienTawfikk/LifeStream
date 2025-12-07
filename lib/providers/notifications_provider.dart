import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_stream/models/notification.dart';

class RealNotificationsNotifier extends StateNotifier<List<Notification>> {
  final Ref ref;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  RealNotificationsNotifier(this.ref) : super([]) {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _subscribeToFriendRequests(user.uid);
        _subscribeToAlerts(user.uid);
        _subscribeToReadStatus(user.uid);
      } else {
        state = [];
      }
    });
  }

  void _subscribeToFriendRequests(String userId) {
    _database
        .ref('friend_requests')
        .orderByChild('receiverId')
        .equalTo(userId)
        .onValue
        .listen(
          (event) {
            _processData();
          },
          onError: (error) {
            // Handle sync error (e.g. permission denied)
            state = []; // Clear state or show error
          },
        );
  }

  void _subscribeToAlerts(String userId) {
    _database
        .ref('users/$userId/alerts')
        .onValue
        .listen(
          (event) {
            _processData();
          },
          onError: (error) {
            // Handle sync error
          },
        );
  }

  // Subscribe to read status to ensure realtime updates for multiple devices
  void _subscribeToReadStatus(String userId) {
    _database
        .ref('users/$userId/read_notifications')
        .onValue
        .listen(
          (event) {
            _processData();
          },
          onError: (error) {
            // Handle sync error
          },
        );
  }

  // Combine and sort logic
  Future<void> _processData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      List<Notification> allNotifications = [];

      // 1. Fetch Friend Requests (Pending)
      final requestsSnapshot = await _database
          .ref('friend_requests')
          .orderByChild('receiverId')
          .equalTo(user.uid)
          .get();
      if (requestsSnapshot.value != null) {
        final data = requestsSnapshot.value as Map;
        data.forEach((key, value) {
          final map = Map<String, dynamic>.from(value as Map);
          if (map['status'] == 'pending') {
            allNotifications.add(
              Notification(
                id: key,
                title: 'New Friend Request',
                message:
                    '${map['senderName'] ?? 'Someone'} sent you a friend request.',
                type: 'info',
                isRead: false,
                timestamp: DateTime.parse(map['timestamp'] as String),
              ),
            );
          }
        });
      }

      // 2. Fetch SOS Alerts
      final alertsSnapshot = await _database
          .ref('users/${user.uid}/alerts')
          .get();
      if (alertsSnapshot.value != null) {
        final data = alertsSnapshot.value as Map;
        data.forEach((key, value) {
          final map = Map<String, dynamic>.from(value as Map);
          allNotifications.add(
            Notification(
              id: key,
              title: 'SOS ALERT: ${map['senderName']}',
              message: map['message'] ?? 'Emergency help needed!',
              type: 'error', // Red color for SOS
              isRead: false,
              timestamp: DateTime.fromMillisecondsSinceEpoch(
                map['timestamp'] as int,
              ),
              latitude: map['latitude'] != null
                  ? (map['latitude'] as num).toDouble()
                  : null,
              longitude: map['longitude'] != null
                  ? (map['longitude'] as num).toDouble()
                  : null,
              bpm: map['bpm'] != null ? (map['bpm'] as num).toInt() : null,
            ),
          );
        });
      }

      // 3. Fetch Read Status
      final readSnapshot = await _database
          .ref('users/${user.uid}/read_notifications')
          .get();
      final Map<dynamic, dynamic> readMap = readSnapshot.value != null
          ? (readSnapshot.value as Map)
          : {};

      // Sort by timestamp descending
      allNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Update isRead status based on Firebase data
      final processedNotifications = allNotifications.map((n) {
        final isRead = readMap.containsKey(n.id);
        return Notification(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          isRead: isRead,
          timestamp: n.timestamp,
          latitude: n.latitude,
          longitude: n.longitude,
          bpm: n.bpm,
        );
      }).toList();

      state = processedNotifications;
    } catch (e) {
      // Handle data processing errors (e.g. parsing, permissions)
      // We could set state to error or just keep previous state
      debugPrint('Error processing notifications: $e');
    }
  }

  Future<void> markAllAsRead() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final unread = state.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return;

    final updates = <String, Object?>{};
    for (var n in unread) {
      updates['users/${user.uid}/read_notifications/${n.id}'] = true;
    }

    try {
      await _database.ref().update(updates);
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Check if already read to avoid redundant writes
    final notification = state.firstWhere(
      (n) => n.id == notificationId,
      orElse: () => Notification(
        id: '',
        title: '',
        message: '',
        type: '',
        timestamp: DateTime.now(),
        isRead: true,
      ),
    );

    if (notification.isRead || notification.id.isEmpty) return;

    try {
      await _database
          .ref('users/${user.uid}/read_notifications/$notificationId')
          .set(true);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }
}

final notificationsProvider =
    StateNotifierProvider<RealNotificationsNotifier, List<Notification>>((ref) {
      return RealNotificationsNotifier(ref);
    });
