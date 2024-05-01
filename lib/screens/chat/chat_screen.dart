import 'package:d_family/widgets/chat_input.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/chat_controller.dart';
import '../../main.dart';
import '../../models/chat_user.dart';
import '../../widgets/app_bars/app_bar_chat.dart';
import '../../widgets/message_card.dart';
import '../../widgets/my_indicator.dart';


class ChatScreen extends GetView<ChatController> {
  final ChatUser user;
   ChatScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace:  buildAppBar(context, controller.repository.user))
      ,
      backgroundColor: const Color.fromARGB(255, 234, 248, 255),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.messages.isEmpty) {
                  return const Center(
                    child: Text('Say Hii! 👋', style: TextStyle(fontSize: 20)),
                  );
                } else {
                  return ListView.builder(
                    reverse: true,
                    itemCount: controller.messages.length,
                    padding: const EdgeInsets.only(top: 8),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return MessageCard(message: controller.messages[index]);
                    },
                  );
                }
              }),
            ),
            if (controller.isUploading.isTrue) buildUploadingIndicator(),
            BuildChatInput(),
            if (controller.showEmoji.isTrue) _buildEmojiPicker(),
          ],
        ),
      ),
    );
  }




  Widget _buildEmojiPicker() {
    // Your emoji picker widget...
    return    SizedBox(
      height: mq.height * .35,
      child: EmojiPicker(
        textEditingController: controller.textController,
        config: const Config(),
      ),
    );
  }
}