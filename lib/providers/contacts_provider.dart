import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_stream/models/emergency_contact.dart';

class ContactsNotifier
    extends StateNotifier<AsyncValue<List<EmergencyContact>>> {
  final Ref ref;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  // Keep track of database subscription
  // ignore: cancel_subscriptions
  Stream<DatabaseEvent>? _stream;

  ContactsNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    final user = _auth.currentUser;
    if (user != null) {
      _subscribeToContacts(user.uid);
    }

    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _subscribeToContacts(user.uid);
      } else {
        state = const AsyncValue.data([]);
      }
    });
  }

  void _subscribeToContacts(String userId) {
    state = const AsyncValue.loading();
    final contactsRef = _database.ref('users/$userId/emergency_contacts');

    // Listen to value changes
    _stream = contactsRef.onValue;
    _stream!.listen(
      (event) {
        final data = event.snapshot.value;
        if (data == null) {
          state = const AsyncValue.data([]);
          return;
        }

        try {
          final Map<dynamic, dynamic> contactsMap =
              data as Map<dynamic, dynamic>;
          final List<EmergencyContact> contacts = contactsMap.entries.map((
            entry,
          ) {
            final contactData = Map<String, dynamic>.from(entry.value as Map);
            // Ensure ID is set from key if missing in value, or just use the object
            if (contactData['id'] == null) {
              contactData['id'] = entry.key;
            }
            return EmergencyContact.fromJson(contactData);
          }).toList();

          state = AsyncValue.data(contacts);
        } catch (e, stack) {
          state = AsyncValue.error(e, stack);
        }
      },
      onError: (error) {
        state = AsyncValue.error(error, StackTrace.current);
      },
    );
  }

  Future<void> addContact(String name, String phone, String relation) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final contactsRef = _database.ref('users/${user.uid}/emergency_contacts');
    final newContactRef = contactsRef.push();

    final newContact = EmergencyContact(
      id: newContactRef.key!,
      name: name,
      phone: phone,
      relation: relation,
    );

    await newContactRef.set(newContact.toJson());
  }

  Future<void> removeContact(String contactId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final contactRef = _database.ref(
      'users/${user.uid}/emergency_contacts/$contactId',
    );
    await contactRef.remove();
  }
}

final contactsProvider =
    StateNotifierProvider<ContactsNotifier, AsyncValue<List<EmergencyContact>>>(
      (ref) {
        return ContactsNotifier(ref);
      },
    );
