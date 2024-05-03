// profile_controller.dart

import 'dart:io';

import 'package:d_family/screens/chat/message_card/message_card_binding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../../api/apis.dart';
import '../helper/dialogs.dart';
import '../screens/auth/login_binding.dart';
import '../screens/auth/login_screen.dart';
import '../screens/chat/message_card/message_card.dart';

class ProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();
  String? image;

  void showBottomSheet() {
    final mq = MediaQuery.of(Get.context!);

    Get.bottomSheet(
      backgroundColor: Colors.cyanAccent.shade200,
      ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(top: mq.size.height * .03, bottom: mq.size.height * .05),
        children: [
          //pick profile picture label
          const Text('Pick Profile Picture',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),

          //for adding some space
          SizedBox(height: mq.size.height * .02),

          //buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //pick from gallery button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  fixedSize: Size(mq.size.width * .3, mq.size.height * .15),
                ),
                onPressed: () => _pickImage(ImageSource.gallery),
                child: Image.asset('images/add_image.png'),
              ),

              //take picture from camera button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  fixedSize: Size(mq.size.width * .3, mq.size.height * .15),
                ),
                onPressed: () => _pickImage(ImageSource.camera),
                child: Image.asset('images/camera.png'),
              ),
            ],
          ),
        ],
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: source);
    if (pickedImage != null) {
      image = pickedImage.path;
      APIs.updateProfilePicture(File(image!));
      Get.back();
    }
  }

  void logout() async {
    Dialogs.showProgressBar(Get.context!);
    await APIs.updateActiveStatus(false);
    await APIs.auth.signOut();
    await GoogleSignIn().signOut();
    Get.until((route) => Get.currentRoute == '/');

    Get.to(() =>  LoginScreen() ,binding : LoginBinding() );
  }
}
