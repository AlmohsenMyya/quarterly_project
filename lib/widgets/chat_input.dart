import 'package:d_family/controllers/chat_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

import '../../api/apis.dart';
import '../../helper/my_date_util.dart';
import '../../models/chat_user.dart';
import '../../screens/view_profile_screen.dart';


class BuildChatInput extends  GetView<ChatController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => controller.toggleEmoji(),
                    icon: const Icon(
                        Icons.emoji_emotions, color: Colors.blueAccent,
                        size: 25),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller.textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Type Something...',
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.pickImage(ImageSource.gallery),
                    icon: const Icon(
                        Icons.image, color: Colors.blueAccent, size: 26),
                  ),
                  IconButton(
                    onPressed: () => controller.pickImage(ImageSource.camera),
                    icon: const Icon(
                        Icons.camera_alt_rounded, color: Colors.blueAccent,
                        size: 26),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () => controller.sendMessage(),
            minWidth: 0,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            shape: const CircleBorder(),
            color: Colors.green,
            child: const Icon(Icons.send, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}


