import 'dart:io';
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

  ChatController(this.repository);

  @override
  void onInit() {
    super.onInit();
    // Fetch messages from the repository
    fetchMessages();
  }

  void fetchMessages() {
    repository.fetchMessages().listen((List<Message> messagesData) {
      messages.assignAll(messagesData);
    });
  }

  void sendMessage() {
    final messageText = textController.text;
    ChatRepository.sendMessage(repository.user,messageText ,Type.text );
    textController.text = '';
  }

  void toggleEmoji() {
    showEmoji.value = !showEmoji.value;
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source, imageQuality: 70);

    if (image != null) {
      isUploading.value = true;
      final file = File(image.path);
      await repository.sendImage(file);
      isUploading.value = false;
    }
  }
}
