
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:greenneeds/model/UserChat.dart';
import 'package:http/http.dart' as http;
import '../firebase_cloud_messaging_key.dart';
import '../ui/chat/chat_screen.dart';

class NotificationService{

  final key=cloudMessagingFirebaseKey;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');


    var initializationSettingsIOS=DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: (int id,String? title,String? body,String? payload) async {});

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid,iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future showNotification({int id=0,String? title,String? body,String? payload})async{
    return flutterLocalNotificationsPlugin.show(id, title, body, notificationDetails());
  }

  notificationDetails(){
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelID', 'channelName',importance: Importance.max,priority: Priority.high,ticker: 'ticker'),
        iOS: DarwinNotificationDetails()
    );
  }

  Future<void> requestPermission() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint(
          'User declined or has not accepted permission');
    }
  }


  Future<void> getToken(String type) async {
    final token =
    await FirebaseMessaging.instance.getToken();
    _saveToken(token!,type);
  }

  Future<void> _saveToken(String token,String type) async {
    if(type=="consumer"){
      await FirebaseFirestore.instance
          .collection('consumers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({'token': token}, SetOptions(merge: true));
    }else{
      await FirebaseFirestore.instance
          .collection('providers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({'token': token}, SetOptions(merge: true));
    }
  }

  String receiverToken = '';

  Future<void> getReceiverToken(String? receiverId,String type) async {

    if(type=="consumer"){
      final getToken = await FirebaseFirestore.instance
          .collection('consumers')
          .doc(receiverId)
          .get();
      receiverToken = await getToken.data()!['token'];
    }else{
      final getToken = await FirebaseFirestore.instance
          .collection('providers')
          .doc(receiverId)
          .get();
      receiverToken = await getToken.data()!['token'];

    }
  }

  void firebaseNotification(context) {
    initNotifications();

    FirebaseMessaging.onMessage
        .listen((RemoteMessage message) async {
      await showNotification(title: message.notification!.title,body: message.notification!.body,);
    });
  }

  Future<void> sendNotificationForProvider(
      {
        required UserChat user,
        required String body,
        required String senderId}) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$key',
        },
        body: jsonEncode(<String, dynamic>{
          "to": receiverToken,
          'priority': 'high',
          'notification': <String, dynamic>{
            'body': "transaction ID: ${user.transactionId} \nmessage: ${body}",
            'title': "${user.name}",
          },
          'data': <String, String>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
            'senderId': senderId,
          }
        }),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  Future<void> sendNotification(
      {
        required UserChat user,
        required String body,
        required String senderId}) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$key',
        },
        body: jsonEncode(<String, dynamic>{
          "to": receiverToken,
          'priority': 'high',
          'notification': <String, dynamic>{
            'body': body,
            'title': "${user.name}",
          },
          'data': <String, String>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
            'senderId': senderId,
          }
        }),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}