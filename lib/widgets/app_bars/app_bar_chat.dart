import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../api/apis.dart';
import '../../helper/my_date_util.dart';
import '../../models/chat_user.dart';
import '../../screens/profile/view_profile_screen.dart';


Widget buildAppBar(BuildContext context, ChatUser user) {
  final mq = MediaQuery.of(context);

  return SafeArea(
    child: InkWell(
      onTap: () => Get.to(() => ViewProfileScreen(user: user)),
      child: StreamBuilder(
        stream: APIs.getUserInfo(user),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading indicator if data is still loading
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Error handling if something went wrong
            return Text('Error: ${snapshot.error}');
          } else {
            // Data is available
            final data = snapshot.data?.docs;
            final list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

            // Return AppBar directly here instead of wrapping with Obx
            return AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: Row(
                children: [
                  // Back button
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back, color: Colors.black54),
                  ),

                  // User profile picture
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.size.height * .03),
                    child: CachedNetworkImage(
                      width: mq.size.height * .05,
                      height: mq.size.height * .05,
                      fit: BoxFit.cover,
                      imageUrl: list.isNotEmpty ? list[0].image : user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),

                  // Spacing
                  const SizedBox(width: 10),

                  // User name & last seen time
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User name
                      Text(
                        list.isNotEmpty ? list[0].name : user.name,
                        style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
                      ),

                      // Spacing
                      const SizedBox(height: 2),

                      // Last seen time of user
                      Text(
                        list.isNotEmpty
                            ? list[0].isOnline ? 'Online' : MyDateUtil.getLastActiveTime(context: context, lastActive: list[0].lastActive)
                            : MyDateUtil.getLastActiveTime(context: context, lastActive: user.lastActive),
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  )
                ],
              ),
            );
          }
        },
      ),
    ),
  );
}

