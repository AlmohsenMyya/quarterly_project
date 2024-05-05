import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../repositry/chat_repo.dart';

class ImageEditorController extends GetxController {
  final File pickedFile;
  final ChatRepository repository;
  ImageEditorController({ required this.pickedFile , required this.repository});
  Rx<File?> croppedFile = Rx<File?>(null);
  RxBool isLoading = false.obs ;



  Future<void> cropImage() async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings
          ()
        ,
        WebUiSettings(
          context: Get.context!,
          presentStyle: CropperPresentStyle.dialog,
          boundary: const CroppieBoundary(
            width: 520,
            height: 520,
          ),)
      ],
    );

    if (croppedFile != null) {
      this.croppedFile.value = File(croppedFile.path);
    }
    }
}