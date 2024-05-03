import 'package:d_family/widgets/chat_input.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/chat_controller.dart';
import '../../main.dart';
import '../../models/chat_user.dart';
import '../../widgets/app_bars/app_bar_chat.dart';
import 'message_card/message_card.dart';
import '../../widgets/my_indicator.dart';
import 'message_card/message_card_binding.dart';


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
      body: DecoratedBox(
        // BoxDecoration takes the image
        decoration: BoxDecoration(
          // Image set to background of the body
          image: DecorationImage(
              image: AssetImage("images/back.jpg"), fit: BoxFit.cover),
        ),
        child: SafeArea(
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
                        final message = controller.messages[index];
                        return GestureDetector(
                          onTap: () => Get.to(
                                () => MessageCard(message: message),
                            binding: MessageDetailBinding(message),
                            arguments: message,
                          ),
                          child: MessageCard(message: message),
                        );
                      },
                    );

                  }
                }),
              ),
              if (controller.isUploading.isTrue) buildUploadingIndicator(),
              BuildChatInput(ontapEmogi: controller.toggleEmoji,),

            ],
          ),
        ),
      ),
    );
  }




}