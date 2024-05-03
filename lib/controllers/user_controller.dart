import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../repositry/chat_repo.dart';
import '../repositry/user_repo.dart';
import '../screens/home/home_binding.dart';
import '../screens/home/home_screen.dart';

class UserController extends GetxController {
  final UserRepository repository;
  final TextEditingController textController = TextEditingController();
  final RxBool isUploading = false.obs;
  final RxBool isAnimate = false.obs;
  final RxList<Message> messages = <Message>[].obs;

  UserController(this.repository);

  @override
  void onInit() {
    super.onInit();
    //for auto triggering animation
    Future.delayed(const Duration(milliseconds: 500), () {
      isAnimate.value = true ;
    });
  }

  // handles google login button click
  handleGoogleBtnClick() {
    //for showing progress bar
    Dialogs.showProgressBar(Get.context!);

    signInWithGoogle().then((user) async {
      //for hiding progress bar
      Navigator.pop(Get.context!);

      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nUserAdditionalInfo: ${user.additionalUserInfo}');

        if (await repository.userExists()) {
          Get.to(() => HomeScreen(), binding: HomeBinding());
        } else {
          await APIs.createUser().then((value) {
            Get.to(() => HomeScreen(), binding: HomeBinding());
          });
        }
      }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle: $e');

      Dialogs.showSnackbar(Get.context!, 'Something Went Wrong (Check Internet!)');

      return null;
    }
  }
}
