import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colo/model/account.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for authenticating the user with firebase
class AuthService {
  /// Auth object
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  /// Getter for the current logged in user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Creates or gets an active user
  Future<User> getOrCreateUser() async {
    if (currentUser == null) {
      await _firebaseAuth.signInAnonymously();
      await _initializeFireStoreAccount();
    }

    return currentUser!;
  }

  /// Sets an default account type
  _initializeFireStoreAccount() async {
    final account = Account();
    account.accountType = 'free';
    account.updated = DateTime.now();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .set(account.toJson());
  }
}