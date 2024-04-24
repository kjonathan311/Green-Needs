
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:greenneeds/model/UserChat.dart';

import '../../model/Message.dart';

class ChatViewModel extends ChangeNotifier{
  ScrollController scrollController = ScrollController();
  final firestore = FirebaseFirestore.instance;
  List<Message> messages = [];

  Future<void> addTextMessage({
    required String content,
    required UserChat user,
  }) async {
    final message = Message(
      content: content,
      sentTime: DateTime.now(),
      receiverId: user.uid,
      messageType: MessageType.text,
      senderId: FirebaseAuth.instance.currentUser!.uid,
      transactionId: user.transactionId
    );
    await _addMessageToChat(user.uid, message,user.type);
  }

  Future<void> addImageMessage({
    required UserChat user,
    required Uint8List file,
  }) async {
    final image = await uploadImage(
        file, 'images/chat/${DateTime.now()}');

    final message = Message(
      content: image,
      sentTime: DateTime.now(),
      receiverId: user.uid,
      messageType: MessageType.image,
      senderId: FirebaseAuth.instance.currentUser!.uid,
      transactionId: user.transactionId
    );
    await _addMessageToChat(user.uid, message,user.type);
  }

  Future<void> _addMessageToChat(
      String receiverId,
      Message message,
      String type
      ) async {

    if(type=="provider"){
      await firestore
          .collection('consumers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('chat')
          .doc(receiverId)
          .collection('messages')
          .add(message.toJson());

      await firestore
          .collection('providers')
          .doc(receiverId)
          .collection('chat')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('messages')
          .add(message.toJson());
    }else{
      await firestore
          .collection('providers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('chat')
          .doc(receiverId)
          .collection('messages')
          .add(message.toJson());

      await firestore
          .collection('consumers')
          .doc(receiverId)
          .collection('chat')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('messages')
          .add(message.toJson());
    }
  }

  Future<String> uploadImage(
      Uint8List file, String storagePath) async =>
      await FirebaseStorage.instance
          .ref()
          .child(storagePath)
          .putData(file)
          .then((task) => task.ref.getDownloadURL());


  Stream<List<Message>> getMessages(UserChat user) {
    if(user.type=="provider"){
      return FirebaseFirestore.instance
          .collection('consumers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('chat')
          .doc(user.uid)
          .collection('messages')
          .orderBy('sentTime', descending: false)
          .where('transactionId', isEqualTo: user.transactionId)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => Message.fromJson(doc.data()))
          .toList());
    }else{
      return FirebaseFirestore.instance
          .collection('providers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('chat')
          .doc(user.uid)
          .collection('messages')
          .orderBy('sentTime', descending: false)
          .where('transactionId', isEqualTo: user.transactionId)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => Message.fromJson(doc.data()))
          .toList());
    }
  }

  void scrollDown() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(
            scrollController.position.maxScrollExtent);
      }
    });
  }
}