
import 'dart:io';

import 'package:d_family/controllers/chat_controller.dart';
import 'package:d_family/controllers/edit_image_controller.dart';
import 'package:get/get.dart';

import '../../models/chat_user.dart';
import '../../repositry/chat_repo.dart';
import 'edit_image.dart';

/// A binding class for the RegisterScreen.
///
/// This class ensures that the RegisterController is created when the
/// RegisterScreen is first loaded.
class EditImageBinding extends Bindings {
  final File pickedFile;
final ChatRepository repository ;
  EditImageBinding(this.pickedFile, this.repository);

  @override
  void dependencies() {
    Get.lazyPut(() => ImageEditorController( pickedFile: pickedFile, repository: repository,) );
  }
}
