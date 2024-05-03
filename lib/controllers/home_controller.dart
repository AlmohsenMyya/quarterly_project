import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../models/chat_user.dart';

class HomeController extends GetxController {
  // for storing all users
  final RxList<ChatUser> userList = <ChatUser>[].obs;

  // for storing searched items
  final RxList<ChatUser> searchList = <ChatUser>[].obs;

  // for storing search status
  final RxBool isSearching = false.obs;

  @override
  void onInit() {
    super.onInit();
    APIs.getSelfInfo();
    fetchAllUsers();
    //for updating user active status according to lifecycle events
    //resume -- active or online
    //pause  -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  Future<void> fetchAllUsers() async {
    final myUsersIdStream = APIs.getMyUsersId();

    final userIds = await myUsersIdStream.first.then((snapshot) =>
        snapshot.docs.map((doc) => doc.id).toList());

    final data = await APIs.getAllUsers(userIds).first;
    final userListData = data.docs
        .map((doc) => ChatUser.fromJson(doc.data()))
        .toList();
    userList.assignAll(userListData);
  }


  // Search users based on name or email
  void searchUsers(String query) {
    searchList.clear();
    for (var user in userList) {
      if (user.name.toLowerCase().contains(query.toLowerCase()) ||
          user.email.toLowerCase().contains(query.toLowerCase())) {
        searchList.add(user);
      }
    }
  }

  // Add a new chat user
  void addChatUser(BuildContext context, String email) async {
    if (email.isNotEmpty) {
      final added = await APIs.addChatUser(email);
      if (!added) {
        Dialogs.showSnackbar(context, 'User does not exist!');
      }
    }
  }

  /// for adding new chat user
  addChatUserDialog() {
    String email = '';

    showDialog(
        context: Get.context!,
        builder: (_) => AlertDialog(
          contentPadding: const EdgeInsets.only(
              left: 24, right: 24, top: 20, bottom: 10),

          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),

          //title
          title: const Row(
            children: [
              Icon(
                Icons.person_add,
                color: Colors.blue,
                size: 28,
              ),
              Text('  Add User')
            ],
          ),

          //content
          content: TextFormField(
            maxLines: null,
            onChanged: (value) => email = value,
            decoration: InputDecoration(
                hintText: 'Email Id',
                prefixIcon: const Icon(Icons.email, color: Colors.blue),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),

          //actions
          actions: [
            //cancel button
            MaterialButton(
                onPressed: () {
                  //hide alert dialog
                  Navigator.pop(Get.context!);
                },
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.blue, fontSize: 16))),

            //add button
            MaterialButton(
                onPressed: () async {
                  //hide alert dialog
                  Navigator.pop(Get.context!);
                  if (email.isNotEmpty) {
                    await APIs.addChatUser(email).then((value) {
                      if (!value) {
                        Dialogs.showSnackbar(
                            Get.context!, 'User does not Exists!');
                      }
                    });
                  }
                },
                child: const Text(
                  'Add',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ))
          ],
        ));
  }
}
