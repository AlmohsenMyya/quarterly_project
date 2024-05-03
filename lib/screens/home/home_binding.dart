
import 'package:d_family/controllers/chat_controller.dart';
import 'package:d_family/controllers/user_controller.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../models/chat_user.dart';
import '../../repositry/chat_repo.dart';
import '../../repositry/user_repo.dart';

/// A binding class for the RegisterScreen.
///
/// This class ensures that the RegisterController is created when the
/// RegisterScreen is first loaded.
class HomeBinding extends Bindings {


  HomeBinding();

  @override
  void dependencies() {

    Get.lazyPut(() => HomeController()  );
  }
}
