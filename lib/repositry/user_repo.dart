import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/chat_user.dart';

class UserRepository {


  UserRepository();
  static FirebaseAuth get auth => FirebaseAuth.instance;

  static User get _my_account => auth.currentUser!;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // for accessing firebase messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;
  // for storing self information
  static ChatUser me = ChatUser(
      id: _my_account.uid,
      name: _my_account.displayName.toString(),
      email: _my_account.email.toString(),
      about: "Hey, I'm using We Chat!",
      image: _my_account.photoURL.toString(),
      createdAt: '',
      isOnline: false,
      lastActive: '',
      pushToken: '');

  // for getting firebase messaging token
   Future<void> getFirebaseMessagingToken() async {

    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('Push Token: $t');
      }
    });

    // for handling foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification!.body} 9999 ');
      }
    });
  }

  // for checking if user exists or not?
   Future<bool> userExists() async {
    return (await _firestore.collection('users').doc(_my_account.uid).get())
        .exists;
  }

// Other user-related operations can be added here...
}
