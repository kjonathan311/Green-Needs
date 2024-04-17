
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService{
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

}