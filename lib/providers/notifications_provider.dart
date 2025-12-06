import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_database/firebase_database.dart';
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
        .listen((event) {
          _processData();
        });
  }

  void _subscribeToAlerts(String userId) {
    _database.ref('users/$userId/alerts').onValue.listen((event) {
      _processData();
    });
  }

  // Combine and sort logic
  Future<void> _processData() async {
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
          ),
        );
      });
    }

    // Sort by timestamp descending
    allNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    state = allNotifications;
  }
}

final notificationsProvider =
    StateNotifierProvider<RealNotificationsNotifier, List<Notification>>((ref) {
      return RealNotificationsNotifier(ref);
    });
