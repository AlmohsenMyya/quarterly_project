import 'package:flutter/material.dart';

typedef AddUserCallback = void Function(String email);

void showAddChatUserDialog(BuildContext context, AddUserCallback onAdd) {
  String email = '';

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      contentPadding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: 10,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Icon(
            Icons.person_add,
            color: Colors.blue,
            size: 28,
          ),
          Text('  Add User'),
        ],
      ),
      content: TextFormField(
        maxLines: null,
        onChanged: (value) => email = value,
        decoration: InputDecoration(
          hintText: 'Email Id',
          prefixIcon: Icon(Icons.email, color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      actions: [
        MaterialButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.blue, fontSize: 16),
          ),
        ),
        MaterialButton(
          onPressed: () {
            onAdd(email); // Call the callback function with the email parameter
            Navigator.pop(context);
          },
          child: Text(
            'Add',
            style: TextStyle(color: Colors.blue, fontSize: 16),
          ),
        ),
      ],
    ),
  );
}
