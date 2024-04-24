import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:greenneeds/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:greenneeds/model/Message.dart';
import 'package:greenneeds/model/UserChat.dart';
import 'package:greenneeds/ui/chat/chat_view_model.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../utils.dart';

class ChatScreen extends StatefulWidget {
  final UserChat user;

  const ChatScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.user.photoUrl != null
                  ? NetworkImage(widget.user.photoUrl!)
                  : const AssetImage('images/placeholder_profile.jpg')
              as ImageProvider<Object>?,
              radius: 20,
            ),
            const SizedBox(width: 10),
            Text(
              widget.user.name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ChatMessages(user: widget.user),
            ),
            ChatTextField(user: widget.user),
          ],
        ),
      ),
    );
  }
}

class ChatMessages extends StatelessWidget {
  final UserChat user;

  const ChatMessages({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: Provider.of<ChatViewModel>(context).getMessages(user),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('belum ada message.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final message = snapshot.data![index];
              final isTextMessage = message.messageType == MessageType.text;
              final isMe = user.uid == message.senderId;

              return MessageBubble(
                isMe: isMe,
                message: message,
                isImage: !isTextMessage, // If it's not a text message, it's an image
              );
            },
          );
        }
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key? key,
    required this.isMe,
    required this.isImage,
    required this.message,
  }) : super(key: key);

  final bool isMe;
  final bool isImage;
  final Message message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.topLeft : Alignment.topRight,
      child: Container(
        decoration: BoxDecoration(
          color: isMe? Color.fromRGBO(156, 175, 170, 1.0):Color.fromRGBO(214, 218, 200, 1.0),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: isMe ? Radius.circular(10) : Radius.circular(0),
            bottomRight: !isMe ? Radius.circular(10) : Radius.circular(0),
          ),
        ),
        margin: const EdgeInsets.only(top: 10, right: 10, left: 10),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            if (isImage)
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: NetworkImage(message.content),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Text(
                message.content,
                style: TextStyle(color: isMe? Colors.white: Colors.black),
              ),
            const SizedBox(height: 5),
            Text(
              timeago.format(message.sentTime),
              style: TextStyle(
                color: isMe? Colors.white: Colors.black,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatTextField extends StatefulWidget {
  final UserChat user;

  const ChatTextField({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<ChatTextField> {
  final controller = TextEditingController();
  final notificationService=NotificationService();

  Uint8List? file;

  @override
  void initState() {
    notificationService.getReceiverToken(widget.user.uid,widget.user.type);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatViewModel = Provider.of<ChatViewModel>(context);
    Future<void> _sendText(BuildContext context) async {
      if (controller.text.isNotEmpty) {
        await chatViewModel.addTextMessage(
          user: widget.user,
          content: controller.text,
        );
        if(widget.user.type=="provider"){
          await notificationService.sendNotificationForProvider(
            user: widget.user,
            body: controller.text,
            senderId: FirebaseAuth.instance.currentUser!.uid,
          );
        }else{
          await notificationService.sendNotification(
            user: widget.user,
            body: controller.text,
            senderId: FirebaseAuth.instance.currentUser!.uid,
          );
        }
        controller.clear();
        FocusScope.of(context).unfocus();
      }
      FocusScope.of(context).unfocus();
    }

    Future<void> _sendImage() async {
      final pickedImage = await MediaService.pickImage();
      setState(() => file = pickedImage);
      if (file != null) {
        await chatViewModel.addImageMessage(
          user: widget.user,
          file: file!,
        );
        await notificationService.sendNotification(
          user: widget.user,
          body: 'image.....',
          senderId: FirebaseAuth.instance.currentUser!.uid,
        );
      }
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.all(15),
            child: TextField(
              decoration: InputDecoration.collapsed(
                  hintText: 'Message'
              ),
              controller: controller,
            ),
          ),
        ),
        const SizedBox(width: 5),
        CircleAvatar(
          radius: 20,
          child: IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: () => _sendText(context),
          ),
        ),
        const SizedBox(width: 5),
        CircleAvatar(
          radius: 20,
          child: IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: _sendImage,
          ),
        ),
      ],
    );
  }
}
