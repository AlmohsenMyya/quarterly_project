import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d_family/repositry/user_repo.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../api/apis.dart';
import '../api/notification_access_token.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';

class ChatRepository {
  final ChatUser user;

  ChatRepository(this.user);

  static FirebaseAuth get auth => FirebaseAuth.instance;

  static User get my_account => auth.currentUser!;
  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  Stream<List<Message>> fetchMessages() {
    return APIs.getAllMessages(user)
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      return snapshot.docs.map((e) => Message.fromJson(e.data())).toList();
    });
  }

  // void sendMessage(String messageText) async {
  //   if (messageText.isNotEmpty) {
  //
  //     //message sending time (also used as id)
  //     final time = DateTime.now().millisecondsSinceEpoch.toString();
  //
  //     //message to send
  //     final Message message = Message(
  //         toId: user.id,
  //         msg: messageText,
  //         read: '',
  //         type: Type.text,
  //         fromId: my_account.uid,
  //         sent: time);
  //
  //     final ref = firestore
  //         .collection('chats/${APIs.getConversationID(user.id)}/messages/');
  //     await ref.doc(time).set(message.toJson()).then((value) =>
  //         APIs.sendPushNotification(user, "msg"));
  //   }
  // }

  Future<void> sendImage(File imageFile) async {
    await APIs.sendChatImage(user, imageFile);
  }

  // for storing self information
  static ChatUser me = ChatUser(
      id: my_account.uid,
      name: my_account.displayName.toString(),
      email: my_account.email.toString(),
      about: "Hey, I'm using We Chat!",
      image: my_account.photoURL.toString(),
      createdAt: '',
      isOnline: false,
      lastActive: '',
      pushToken: '');


  // for sending push notification (Updated Codes)
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "message": {
          "token": chatUser.pushToken,
          "notification": {
            "title": me.name, //our name should be send
            "body": msg,
          },
        }
      };

      // Firebase Project > Project Settings > General Tab > Project ID
      const projectID = 'dater-4992c';

      // get firebase admin token
      final bearerToken = await NotificationAccessToken.getToken;

      log('bearerToken: $bearerToken');

      // handle null token
      if (bearerToken == null) return;

      var res = await post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/$projectID/messages:send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $bearerToken'
        },
        body: jsonEncode(body),
      );

      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }



  // for adding an chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != my_account.uid) {
      //user exists

      log('user exists: ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(my_account.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists

      return false;
    }
  }

  // for getting current user info
   Future<void> getSelfInfo() async {
     UserRepository _userRepository = UserRepository();
    await firestore
        .collection('users')
        .doc(my_account.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await _userRepository.getFirebaseMessagingToken();

        //for setting user status to active
        APIs.updateActiveStatus(true);
        log('My Data: ${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: my_account.uid,
        name: my_account.displayName.toString(),
        email: my_account.email.toString(),
        about: "Hey, I'm using We Chat!",
        image: my_account.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');

    return await firestore
        .collection('users')
        .doc(my_account.uid)
        .set(chatUser.toJson());
  }

  // for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(my_account.uid)
        .collection('my_users')
        .snapshots();
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\nUserIds: $userIds');

    return firestore
        .collection('users')
        .where('id',
            whereIn: userIds.isEmpty
                ? ['']
                : userIds) //because empty list throws an error
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(my_account.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }



  // update profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    //storage file ref with path
    final ref = storage.ref().child('profile_pictures/${my_account.uid}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(my_account.uid)
        .update({'image': me.image});
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(my_account.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  ///************** Chat Screen Related APIs **************

  // chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)

  // useful for getting conversation id
  static String getConversationID(String id) =>
      my_account.uid.hashCode <= id.hashCode
          ? '${my_account.uid}_$id'
          : '${id}_${my_account.uid}';

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
      sentDoc: time,
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: my_account.uid,
        sent: FieldValue.serverTimestamp());

    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  }

  // //update read status of message
  // static Future<void> updateMessageReadStatus(Message message) async {
  //   firestore
  //       .collection('chats/${getConversationID(message.fromId)}/messages/')
  //       .doc(message.sentDoc)
  //       .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  // }

  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  //delete message
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sentDoc)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sentDoc)
        .update({'msg': updatedMsg});
  }
}
