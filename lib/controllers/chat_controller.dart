import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../repositry/chat_repo.dart';

class ChatController extends GetxController {
  final ChatRepository repository;
  final TextEditingController textController = TextEditingController();
  final RxBool showEmoji = false.obs;
  final RxBool isUploading = false.obs;
  final RxList<Message> messages = <Message>[].obs;

  // for authentication
  static FirebaseAuth get auth => FirebaseAuth.instance;
  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  ChatController(this.repository);
  static User get my_account => auth.currentUser!;
  static late ChatUser me; // for storing self information

  @override
  void onInit() {
    super.onInit();
    // Fetch messages from the repository
    fetchMessages();
    me = ChatUser(
        id: my_account.uid,
        name: my_account.displayName.toString(),
        email: my_account.email.toString(),
        about: "Hey, I'm using We Chat!",
        image: my_account.photoURL.toString(),
        createdAt: '',
        isOnline: false,
        lastActive: '',
        pushToken: '');
  }

  void fetchMessages() {
    repository.fetchMessages().listen((List<Message> messagesData) {
      messages.assignAll(messagesData);
    });
  }

  void sendMessage() {
    final messageText = textController.text;
    ChatRepository.sendMessage(repository.user, messageText, Type.text);
    textController.text = '';
  }

  void toggleEmoji() {
    print("${showEmoji.value}");
    showEmoji.value = !showEmoji.value;
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: source, imageQuality: 70);

    if (image != null) {
      isUploading.value = true;
      final file = File(image.path);
      await repository.sendImage(file);
      isUploading.value = false;
    }
  }

  // useful for getting conversation id
  static String getConversationID(String id) =>
      my_account.uid.hashCode <= id.hashCode
          ? '${my_account.uid}_$id'
          : '${id}_${my_account.uid}';

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
