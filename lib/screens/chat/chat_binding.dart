
import 'package:d_family/controllers/chat_controller.dart';
import 'package:get/get.dart';

import '../../models/chat_user.dart';
import '../../repositry/chat_repo.dart';

/// A binding class for the RegisterScreen.
///
/// This class ensures that the RegisterController is created when the
/// RegisterScreen is first loaded.
class ChatBinding extends Bindings {
  final ChatUser user;

  ChatBinding(this.user);

  @override
  void dependencies() {
    final ChatRepository repository = new ChatRepository(user);
    Get.lazyPut(() => ChatController(repository) );
  }
}
