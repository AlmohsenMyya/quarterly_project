import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/apis.dart';
import '../../../models/message.dart';
import '../../../controllers/message_card_controller.dart';

class MessageCard extends StatelessWidget {
  final Message message;

  const MessageCard({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MessageDetailController(message));

    bool isMe = APIs.my_account.uid == message.fromId;
    return InkWell(
      onLongPress: () => _showBottomSheet(context, controller, isMe),
      child: isMe ? _greenMessage(controller) : _blueMessage(controller),
    );
  }

  Widget _blueMessage(MessageDetailController controller) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(message.type == Type.image ? 10 : 12),
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 221, 245, 255),
              border: Border.all(color: Colors.lightBlue),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: _buildMessageContent(),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: FutureBuilder<String>(
            future: controller.getFormattedSentTime(message),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // While the future is loading, return a placeholder or loading indicator
                return Text("...");
              } else if (snapshot.hasError) {
                // If an error occurred, handle it accordingly
                return Text('...');
              } else {
                // If the future has completed successfully, display the formatted time
                return Text(
                  snapshot.data!,
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _greenMessage(MessageDetailController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: 12),
            if (message.read.isNotEmpty)
              const Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 20,
              ),
            const SizedBox(width: 2),
            FutureBuilder<String>(
              future: controller.getFormattedSentTime(message),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // While the future is loading, return a placeholder or loading indicator
                  return Text("...");
                } else if (snapshot.hasError) {
                  // If an error occurred, handle it accordingly
                  return Text('....');
                } else {
                  // If the future has completed successfully, display the formatted time
                  return Text(
                    snapshot.data!,
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                  );
                }
              },
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(message.type == Type.image ? 10 : 12),
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 218, 255, 176),
              border: Border.all(color: Colors.lightGreen),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: _buildMessageContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageContent() {
    return message.type == Type.text
        ? Text(
            message.msg,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              message.msg,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const CircularProgressIndicator();
              },
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error),
            ),
          );
  }

  void _showBottomSheet(
    BuildContext context,
    MessageDetailController controller,
    bool isMe,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: [
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 100),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            if (message.type == Type.image)
              _OptionItem(
                icon: const Icon(Icons.download_rounded, color: Colors.blue),
                name: 'Save Image',
                onTap: () {
                  controller.saveImage(message);
                },
              ),
            if (isMe)
              _OptionItem(
                icon: const Icon(Icons.edit, color: Colors.blue),
                name: 'Edit Message',
                onTap: () => _showMessageUpdateDialog(context, controller),
              ),
            if (isMe)
              _OptionItem(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                name: 'Delete Message',
                onTap: () {
                  controller.deleteMessage(message);
                  Get.back();
                },
              ),
            const Divider(color: Colors.black54),
            _OptionItem(
              icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
              name: 'Sent At: ${controller.getFormattedSentTime(message)}',
              onTap: () {},
            ),
            _OptionItem(
              icon: const Icon(Icons.remove_red_eye, color: Colors.green),
              name: 'Read At: ${controller.getFormattedReadTime(message)}',
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  void _showMessageUpdateDialog(
      BuildContext context, MessageDetailController controller) {
    String updatedMsg = message.msg;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Update Message'),
        content: TextFormField(
          initialValue: updatedMsg,
          maxLines: null,
          onChanged: (value) => updatedMsg = value,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          MaterialButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.blue, fontSize: 16)),
          ),
          MaterialButton(
            onPressed: () {
              controller.editMessage(message, updatedMsg);
              Get.back();
            },
            child: const Text('Update',
                style: TextStyle(color: Colors.blue, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
