import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  Message({
    required this.toId,
    required this.msg,
    required this.read,
    required this.type,
    required this.fromId,
    required this.sent,
    this.sentDoc
  });

  late final String toId;
  late final String msg;
  late final String read;
  late final String fromId;
  late final dynamic sent;
  late final Type type;
  late final dynamic sentDoc ;

  Message.fromJson(Map<String, dynamic> json) {
    print("---------------------- ${json['sent']}");
    toId = json['toId'].toString();
    msg = json['msg'].toString();
    read = json['read'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    fromId = json['fromId'].toString();
    sent = convertTimestampToMilliseconds(json['sent']);
    sentDoc = convertTimestampToMillisecondsDocs(json['sentDoc']) ?? "59856566555";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['toId'] = toId;
    data['msg'] = msg;
    data['read'] = read;
    data['type'] = type.name;
    data['fromId'] = fromId;
    data['sent'] = sent;
    data['sentDoc']=sentDoc;
    return data;
  }
  dynamic convertTimestampToMilliseconds(dynamic sent) {
    if (sent is Timestamp) {
      // Convert Timestamp to DateTime
      DateTime dateTime = sent.toDate();

      // Convert DateTime to local timezone
      DateTime localDateTime = dateTime.toLocal();

      // Convert local DateTime to milliseconds
      int milliseconds = localDateTime.millisecondsSinceEpoch;

      // Return the milliseconds as a string
      return milliseconds.toString();
    } else {
      // Return the original value if it's not a Timestamp
      return sent.toString();
    }
  }
  dynamic convertTimestampToMillisecondsDocs(dynamic sent) {
    if (sent is Timestamp) {
      // Convert Timestamp to DateTime
      // DateTime dateTime = sent.toDate();


      // Convert local DateTime to milliseconds
      int milliseconds = sent.millisecondsSinceEpoch;

      // Return the milliseconds as a string
      return milliseconds.toString();
    } else {
      // Return the original value if it's not a Timestamp
      return sent.toString();
    }
  }
}

enum Type { text, image }
