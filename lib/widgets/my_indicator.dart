import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


Widget buildUploadingIndicator() {
  // Your uploading indicator widget...
  return  const Align(
      alignment: Alignment.centerRight,
      child: Padding(
          padding:
          EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          child: CircularProgressIndicator(strokeWidth: 2)));
}