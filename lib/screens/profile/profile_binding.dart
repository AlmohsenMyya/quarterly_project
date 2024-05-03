
import 'package:d_family/controllers/chat_controller.dart';
import 'package:d_family/controllers/user_controller.dart';
import 'package:get/get.dart';

import '../../controllers/update_profile_controller.dart';
import '../../models/chat_user.dart';
import '../../repositry/chat_repo.dart';
import '../../repositry/user_repo.dart';

/// A binding class for the RegisterScreen.
///
/// This class ensures that the RegisterController is created when the
/// RegisterScreen is first loaded.
class ProfileBinding extends Bindings {


  ProfileBinding();

  @override
  void dependencies() {

    Get.lazyPut(() => ProfileController()  );
  }
}
