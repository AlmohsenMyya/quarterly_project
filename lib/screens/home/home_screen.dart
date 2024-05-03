import 'package:d_family/screens/profile/profile_binding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/apis.dart';
import '../../controllers/home_controller.dart';
import '../../main.dart';
import '../../models/chat_user.dart';
import '../../widgets/chat_user_card.dart';
import '../../widgets/dialogs/add_chatuser_dialog.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  final HomeController _controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
  canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: const Icon(CupertinoIcons.home),
          title: Obx(() => _controller.isSearching.value
              ? TextField(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Name, Email, ...',
            ),
            autofocus: true,
            style: TextStyle(fontSize: 17, letterSpacing: 0.5),
            onChanged: _controller.searchUsers,
          )
              : Text('We Chat')),
          actions: [
            IconButton(
              onPressed: () {
                _controller.isSearching.toggle();
              },
              icon: Icon(_controller.isSearching.value
                  ? Icons.clear
                  : Icons.search),
            ),
            IconButton(
              onPressed: () {
                Get.to(() => ProfileScreen(user: APIs.me), binding: ProfileBinding());
              },
              icon: Icon(Icons.more_vert),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showAddChatUserDialog(context, (String email) {
              _controller.addChatUser(context, email);
            });
          },
          child: Icon(Icons.add_comment_rounded),
        ),
        body: DecoratedBox(
          // BoxDecoration takes the image
          decoration: BoxDecoration(
            // Image set to background of the body
            image: DecorationImage(
                image: AssetImage("images/back.jpg"), fit: BoxFit.cover),
          ),
          child: Obx(
                () => ListView.builder(
              itemCount: _controller.isSearching.value
                  ? _controller.searchList.length
                  : _controller.userList.length,
              padding: EdgeInsets.only(top: mq.height * .01),
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return ChatUserCard(
                  user: _controller.isSearching.value
                      ? _controller.searchList[index]
                      : _controller.userList[index],
                );
              },
            ),
          ),
        ),
      ),
    );
  }


}
