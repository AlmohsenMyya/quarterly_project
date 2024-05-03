import 'package:get/get.dart';

import '../../../controllers/message_card_controller.dart';
import '../../../models/message.dart';

/// A binding class for the RegisterScreen.
///
/// This class ensures that the RegisterController is created when the
/// RegisterScreen is first loaded.
class MessageDetailBinding extends Bindings {
  final Message message;

  MessageDetailBinding(this.message);

  @override
  void dependencies() {
    Get.lazyPut(() => MessageDetailController(message));
  }
}
