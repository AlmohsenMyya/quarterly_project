import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gallery_saver_updated/gallery_saver.dart';
import 'package:flutter/material.dart';
import '../api/apis.dart';
import '../helper/my_date_util.dart';
import '../models/message.dart';

class MessageDetailController extends GetxController {
  final Message message;

  MessageDetailController(this.message);

  Future<void> saveImage(Message message) async {
    try {


      await GallerySaver.saveImage(message.msg, albumName: 'We Chat');
      Get.showSnackbar(GetSnackBar(
        message: "image saved !!",
        backgroundColor: Colors.greenAccent,
        duration: Duration(milliseconds: 900),
      ));
    } catch (e) {
      print("${message.msg} $e");
      Get.showSnackbar(GetSnackBar(
        message: "check your internet",
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 900),
      ));
      // Handle error
    }
  }

  void copyText(Message message) {
    Clipboard.setData(ClipboardData(text: message.msg))
        .then((_) => Get.snackbar('Copied', 'Text copied successfully'));
  }

  void editMessage(Message message, String updatedMessage) {
    APIs.updateMessage(message, updatedMessage);
  }

  void deleteMessage(Message message) {
    APIs.deleteMessage(message);
  }

  Future<String> getFormattedSentTime(Message message) {
    return MyDateUtil.getFormattedTime(
      context: Get.context!,
      time: message.sent,
    );
  }

  String getFormattedReadTime(Message message) {
    return message.read.isEmpty
        ? 'Not seen yet'
        : MyDateUtil.getMessageTime(context: Get.context!, time: message.read);
  }

  void updateMessageReadStatus (Message message){
    APIs.updateMessageReadStatus(message);
  }
}
