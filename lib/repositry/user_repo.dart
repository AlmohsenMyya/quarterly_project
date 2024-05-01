import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/chat_user.dart';

class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get the current authenticated user
  Future<ChatUser?> getCurrentUser() async {
    final User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
      await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (snapshot.exists) {
        return ChatUser.fromJson(snapshot.data()!);
      }
    }
    return null;
  }

  // Update user profile
  Future<void> updateProfile(ChatUser user) async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        await _firestore.collection('users').doc(firebaseUser.uid).update(user.toJson());
      }
    } catch (e) {
      log('Error updating user profile: $e');
    }
  }

  // Get all users
  Future<List<ChatUser>> getAllUsers() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await _firestore.collection('users').get();
      return querySnapshot.docs.map((doc) => ChatUser.fromJson(doc.data())).toList();
    } catch (e) {
      log('Error fetching all users: $e');
      return [];
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      log('Error signing in with email and password: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log('Error signing out: $e');
    }
  }

// Other user-related operations can be added here...
}
