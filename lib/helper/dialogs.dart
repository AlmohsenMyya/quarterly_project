import 'package:flutter/material.dart';

class Dialogs {
  static void showSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: Colors.blue.withOpacity(.8),
        behavior: SnackBarBehavior.floating));
  }
  static void showErrorSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(

      duration: Duration(milliseconds: 600),
        content: Text(msg),
        backgroundColor: Colors.red.withOpacity(.8),
        behavior: SnackBarBehavior.fixed));
  }
  static void showProgressBar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => const Center(
                child: CircularProgressIndicator(
              strokeWidth: 1,
            )));
  }
}
