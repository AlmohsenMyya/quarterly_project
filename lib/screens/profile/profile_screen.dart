import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:d_family/controllers/update_profile_controller.dart';
import 'package:d_family/helper/my_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../../api/apis.dart';
import '../../controllers/user_controller.dart';
import '../../helper/dialogs.dart';
import '../../main.dart';
import '../../models/chat_user.dart';
import '../auth/login_screen.dart';

//profile screen -- to show signed in user info
class ProfileScreen extends GetView<ProfileController> {
  final ChatUser user;

  ProfileScreen({super.key, required this.user});

  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard
      onTap: FocusScope
          .of(context)
          .unfocus,
      child: Scaffold(
        //app bar
          appBar: AppBar(title: const Text(MyString.profileScreenTitle)),

          //floating button to log out

          //body
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // for adding some space
                    SizedBox(width: mq.width, height: mq.height * .03),

                    //user profile picture
                    Stack(
                      children: [
                        //profile picture
                        _image != null
                            ?

                        //local image
                        ClipRRect(
                            borderRadius:
                            BorderRadius.circular(mq.height * .1),
                            child: Image.file(File(_image!),
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover))
                            :

                        //image from server
                        ClipRRect(
                          borderRadius:
                          BorderRadius.circular(mq.height * .1),
                          child: CachedNetworkImage(
                            width: mq.height * .2,
                            height: mq.height * .2,
                            fit: BoxFit.cover,
                            imageUrl: user.image,
                            errorWidget: (context, url, error) =>
                            const CircleAvatar(
                                child: Icon(CupertinoIcons.person)),
                          ),
                        ),

                        //edit image button
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                            elevation: 1,
                            onPressed: () {
                              controller.showBottomSheet();
                            },
                            shape: const CircleBorder(),
                            color: Colors.white,
                            child: const Icon(Icons.edit, color: Colors.blue),
                          ),
                        )
                      ],
                    ),

                    // for adding some space
                    SizedBox(height: mq.height * .03),

                    // user email label
                    Text(user.email,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 16)),

                    // for adding some space
                    SizedBox(height: mq.height * .05),

                    // name input field
                    TextFormField(
                      initialValue: user.name,
                      onChanged: (val) {
                        if (APIs.me.name == val) {
                          controller.can_update_name.value = false;
                        }else{

                          controller.can_update_name.value = true;
                        }
                      },
                      onSaved: (val) => APIs.me.name = val ?? '',
                      validator: (val) =>
                      val != null && val.isNotEmpty
                          ? null
                          : MyString.requiredField,
                      decoration: InputDecoration(
                          prefixIcon:
                          const Icon(Icons.person, color: Colors.blue),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'D . Family',
                          label: const Text(MyString.nameInputLabel)),
                    ),

                    // for adding some space
                    SizedBox(height: mq.height * .02),

                    // about input field
                    TextFormField(
                      initialValue: user.about,
                      onChanged: (val) {

                        print("$val ***/*///* ${APIs.me.about } //**// ${controller.can_update_about.value}");
                        if (APIs.me.about == val) {
                          controller.can_update_about.value = false;
                        }else{

                          controller.can_update_about.value = true;
                        }
                      },
                      onSaved: (val) => APIs.me.about = val ?? '',
                      validator: (val) {
                        return val != null && val.isNotEmpty
                            ? null
                            : MyString.requiredField;
                      },
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.info_outline,
                              color: Colors.blue),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'eg. Feeling Happy',
                          label: const Text('About')),
                    ),

                    // for adding some space
                    SizedBox(height: mq.height * .05),

                    // update profile button
                   Obx(() =>  ElevatedButton.icon(
                     style: ElevatedButton.styleFrom(
                         backgroundColor: (controller.can_update_name.value ==
                             true ||
                             controller.can_update_about.value == true)
                             ? Colors.greenAccent : Colors.white24,
                         shape: const StadiumBorder(),
                         minimumSize: Size(mq.width * .5, mq.height * .06)),
                     onPressed: () {
                       if (_formKey.currentState!.validate()) {
                         _formKey.currentState!.save();
                         if ((controller.can_update_name.value ==
                             true ||
                             controller.can_update_about.value == true)) {
                           APIs.updateUserInfo().then((value) {
                             Dialogs.showSnackbar(
                                 context, 'Profile Updated Successfully!');
                           }); } else {
                           Dialogs.showErrorSnackbar(
                               context, MyString.noThingChange );
                         }
                       }
                     },
                     icon: Icon(Icons.edit, size: 28),
                     label:
                     const Text('UPDATE', style: TextStyle(fontSize: 16)),
                   ) ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 10 , top:  50),
                      child: FloatingActionButton.extended(
                          backgroundColor: Colors.redAccent,
                          onPressed: () async {
                            controller.logout();
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text(MyString.logoutButtonLabel)),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
