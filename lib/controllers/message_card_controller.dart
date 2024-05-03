import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gallery_saver_updated/gallery_saver.dart';

import '../api/apis.dart';
import '../helper/my_date_util.dart';
import '../models/message.dart';



class MessageDetailController extends GetxController {
  final Message message;

  MessageDetailController(this.message);

  Future<void> saveImage( Message message) async {
    try {
      Get.showSnackbar(GetSnackBar(message: "image saved !!",backgroundColor: Color.fromRGBO(0, 20, 0,50),duration: Duration(milliseconds: 900),));

      await GallerySaver.saveImage(message.msg, albumName: 'We Chat');
       } catch (e) {
      print("${message.msg} $e");
      // Handle error
    }
  }

  void copyText(Message message) {
    Clipboard.setData(ClipboardData(text: message.msg))
        .then((_) => Get.snackbar('Copied', 'Text copied successfully'));
  }

  void editMessage(Message message,String updatedMessage) {
    APIs.updateMessage(message, updatedMessage);
  }

  void deleteMessage(Message message) {
    APIs.deleteMessage(message);
  }

  String getFormattedSentTime( Message message) {
    print(" getFormattedSentTime ${message.msg}");
    return MyDateUtil.getFormattedTime(
      context: Get.context!,
      time: message.sent,
    );
  }

  String getFormattedReadTime( Message message) {
    return message.read.isEmpty
        ? 'Not seen yet'
        : MyDateUtil.getMessageTime(context: Get.context!, time: message.read);
  }
}
