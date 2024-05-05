import 'package:d_family/controllers/chat_controller.dart';
import 'package:d_family/helper/dialogs.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

import '../../api/apis.dart';
import '../../helper/my_date_util.dart';
import '../../models/chat_user.dart';
import '../main.dart';
import '../screens/profile/view_profile_screen.dart';


class BuildChatInput extends  GetView<ChatController> {
  Function ontapEmogi ;
  BuildChatInput({super.key, required this.ontapEmogi});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          controller.toggleEmoji();
                        },
                        icon: const Icon(Icons.emoji_emotions,
                            color: Colors.blueAccent, size: 25),
                      ),
                      Expanded(
                        child: SingleChildScrollView( // Wrap with SingleChildScrollView
                          scrollDirection: Axis.horizontal, // Set scroll direction
                          child: ConstrainedBox( // Limit max width
                            constraints: const BoxConstraints(maxWidth: 300, maxHeight: 200), // Adjust maxWidth as needed
                            child: TextField(
                              controller: controller.textController,
                              keyboardType: TextInputType.multiline,
                              onChanged: (val) {
                                if (val.isEmpty) {
                                  controller.isGreen.value = false;
                                } else {
                                  controller.isGreen.value = true;
                                }
                              },
                              maxLines: null,
                              maxLength: 1000, // Limit the maximum number of words
                              maxLengthEnforcement: MaxLengthEnforcement.enforced,
                              decoration: const InputDecoration(
                                hintText: 'Type Something...',
                                hintStyle: TextStyle(color: Colors.blueAccent),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            controller.pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.image,
                            color: Colors.blueAccent, size: 26),
                      ),
                      IconButton(
                        onPressed: () =>
                            controller.pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_rounded,
                            color: Colors.blueAccent, size: 26),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
              Obx(
                () => (controller.isGreen.isTrue) ? sendGreen() : sendBlack(),
              )
            ],
          ),
          Obx(
            () => (controller.showEmoji.isTrue)
                ? _buildEmojiPicker()
                : SizedBox(),
          )
        ],
      ),
    );
  }

  Widget sendGreen() {
    return MaterialButton(
      onPressed: () {
        controller.sendMessage();
      },
      minWidth: 0,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      shape: const CircleBorder(),
      color: Colors.green,
      child: const Icon(Icons.send, color: Colors.white, size: 28),
    );
  }

  Widget sendBlack() {
    return MaterialButton(
      onPressed: () {
        Dialogs.showErrorSnackbar(Get.context!, "Type SomeThing please ..");
      },
      minWidth: 0,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      shape: const CircleBorder(),
      color: Colors.black,
      child: const Icon(Icons.send, color: Colors.white, size: 28),
    );
  }

  Widget _buildEmojiPicker() {
    // Your emoji picker widget...
    return SizedBox(
      height: mq.height * .35,
      child: EmojiPicker(
        textEditingController: controller.textController,
        config: const Config(),
      ),
    );
  }
}
