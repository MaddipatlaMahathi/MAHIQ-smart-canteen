import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    // Request permission
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get the token
    String? token = await _fcm.getToken();
    print("FCM Token: \$token");

    // Handle background messages (setup needed in main.dart)
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: \${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: \${message.notification}');
      }
    });
  }
}
