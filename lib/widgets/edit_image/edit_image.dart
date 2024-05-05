import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/edit_image_controller.dart';
import 'dart:io';

class ImageEditorPage extends GetView<ImageEditorController> {
  final File pickedFile;

  ImageEditorPage({super.key, required this.pickedFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Send Image'), actions: [
          ElevatedButton(
            onPressed: () async {
              controller.isLoading.value = true;
              await controller.repository
                  .sendImage(pickedFile)
                  .then((value) => controller.isLoading.value = true);
              Get.back();
            },
            child: Icon(Icons.check),
          ),
        ]),
        body: Obx(
          () =>   controller.isLoading.isTrue
              ? Center(child: CircularProgressIndicator())
              :ListView(
            children: [
             Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Image.file(controller.pickedFile),
                    ),
            ],
          ),
        ));
  }
}
