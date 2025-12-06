import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_stream/models/friend_request.dart';
import 'package:life_stream/models/user.dart';

// State classes
class FriendsState {
  final List<User> friends;
  final List<FriendRequest> sentRequests;
  final List<FriendRequest> receivedRequests;
  final bool isLoading;
  final String? error;

  FriendsState({
    this.friends = const [],
    this.sentRequests = const [],
    this.receivedRequests = const [],
    this.isLoading = false,
    this.error,
  });

  FriendsState copyWith({
    List<User>? friends,
    List<FriendRequest>? sentRequests,
    List<FriendRequest>? receivedRequests,
    bool? isLoading,
    String? error,
  }) {
    return FriendsState(
      friends: friends ?? this.friends,
      sentRequests: sentRequests ?? this.sentRequests,
      receivedRequests: receivedRequests ?? this.receivedRequests,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class FriendsNotifier extends StateNotifier<FriendsState> {
  final Ref ref;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  FriendsNotifier(this.ref) : super(FriendsState()) {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _subscribeToFriends(user.uid);
        _subscribeToRequests(user.uid);
      } else {
        state = FriendsState();
      }
    });
  }

  void _subscribeToFriends(String userId) {
    _database
        .ref('users/$userId/friends')
        .onValue
        .listen(
          (event) async {
            final data = event.snapshot.value;
            if (data == null) {
              state = state.copyWith(friends: []);
              return;
            }

            final friendIds = (data as Map).keys.toList();
            final List<User> loadedFriends = [];

            // Fetch friend details (ideally this should be optimized or denormalized)
            // For now we fetch each friend's profile
            for (var friendId in friendIds) {
              if (friendId == userId) {
                continue; // SAFEGUARD: Never show self in friend list
              }

              final friendSnapshot = await _database
                  .ref('users/$friendId/profile')
                  .get();
              if (friendSnapshot.value != null) {
                final friendData = Map<String, dynamic>.from(
                  friendSnapshot.value as Map,
                );
                friendData['id'] = friendId;
                // Ensure mandatory fields exist to avoid parsing error
                if (!friendData.containsKey('name')) {
                  friendData['name'] = 'Unknown';
                }
                if (!friendData.containsKey('email')) {
                  friendData['email'] = '';
                }
                if (!friendData.containsKey('createdAt')) {
                  friendData['createdAt'] = DateTime.now().toIso8601String();
                }

                loadedFriends.add(User.fromJson(friendData));
              }
            }

            state = state.copyWith(friends: loadedFriends);
            state = state.copyWith(friends: loadedFriends);
          },
          onError: (error) {
            // Handle permission/sync errors
            state = state.copyWith(error: error.toString(), friends: []);
          },
        );
  }

  void _subscribeToRequests(String userId) {
    _database
        .ref('friend_requests')
        .orderByChild('receiverId')
        .equalTo(userId)
        .onValue
        .listen(
          (event) {
            _processRequests(event, isReceived: true);
          },
          onError: (error) {
            // Handle error
          },
        );

    _database
        .ref('friend_requests')
        .orderByChild('senderId')
        .equalTo(userId)
        .onValue
        .listen(
          (event) {
            _processRequests(event, isReceived: false);
          },
          onError: (error) {
            // Handle error
          },
        );
  }

  void _processRequests(DatabaseEvent event, {required bool isReceived}) {
    final data = event.snapshot.value;
    final List<FriendRequest> requests = [];
    if (data != null) {
      final map = data as Map;
      map.forEach((key, value) {
        final reqData = Map<String, dynamic>.from(value as Map);
        reqData['id'] = key;
        requests.add(FriendRequest.fromJson(reqData));
      });
    }

    if (isReceived) {
      state = state.copyWith(receivedRequests: requests);
    } else {
      state = state.copyWith(sentRequests: requests);
    }
  }

  Future<List<User>> searchUsers(String query) async {
    try {
      final snapshot = await _database.ref('users').get();
      if (snapshot.value == null) return [];

      final usersMap = snapshot.value as Map;
      final List<User> results = [];
      final q = query.toLowerCase().trim();

      usersMap.forEach((key, value) {
        if (key == _auth.currentUser?.uid) return; // Exclude self

        // Robust parsing: 'users/{id}/profile'
        final userData = value['profile'];
        if (userData != null) {
          final userMap = Map<String, dynamic>.from(userData as Map);
          userMap['id'] = key;

          // Search logic
          final name = (userMap['name'] ?? '').toString().toLowerCase();
          final email = (userMap['email'] ?? '').toString().toLowerCase();

          // If query is empty, add everyone. Else match query.
          if (q.isEmpty || name.contains(q) || email.contains(q)) {
            // Ensure mandatory fields
            if (!userMap.containsKey('name')) userMap['name'] = 'Unknown';
            if (!userMap.containsKey('email')) userMap['email'] = '';
            if (!userMap.containsKey('createdAt')) {
              userMap['createdAt'] = DateTime.now().toIso8601String();
            }

            results.add(User.fromJson(userMap));
          }
        }
      });

      return results;
    } catch (e) {
      return [];
    }
  }

  Future<void> sendRequest(User receiver) async {
    final sender = _auth.currentUser;
    if (sender == null) return;

    // Check if already friends or requested or SELF
    if (receiver.id == sender.uid) return; // SAFEGUARD: Prevent self-request
    if (state.friends.any((u) => u.id == receiver.id)) return;
    if (state.sentRequests.any(
      (r) => r.receiverId == receiver.id && r.status == RequestStatus.pending,
    )) {
      return;
    }

    final newRequestRef = _database.ref('friend_requests').push();
    final request = FriendRequest(
      id: newRequestRef.key!,
      senderId: sender.uid,
      senderName: sender.displayName ?? 'Unknown',
      senderEmail: sender.email ?? '',
      receiverId: receiver.id,
      status: RequestStatus.pending,
      timestamp: DateTime.now(),
    );

    await newRequestRef.set(request.toJson());
  }

  Future<void> acceptRequest(FriendRequest request) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Determine the ID of the friend (the one who isn't the current user)
    // This handles cases where we might be acting on a request weirdly
    final friendId = request.senderId == currentUser.uid
        ? request.receiverId
        : request.senderId;

    if (friendId == currentUser.uid) {
      // Prevent self-friending
      return;
    }

    // 1. Update request status
    await _database.ref('friend_requests/${request.id}').update({
      'status': RequestStatus.accepted.name,
    });

    // 2. Add to friends list for both
    await _database.ref('users/${currentUser.uid}/friends/$friendId').set(true);
    await _database.ref('users/$friendId/friends/${currentUser.uid}').set(true);
  }

  Future<void> rejectRequest(String requestId) async {
    await _database.ref('friend_requests/$requestId').update({
      'status': RequestStatus.rejected.name,
    });
  }
}

final friendsProvider = StateNotifierProvider<FriendsNotifier, FriendsState>((
  ref,
) {
  return FriendsNotifier(ref);
});
