import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:http/http.dart' as http;

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _messaging.getToken();
      if (token != null) {
        await _registerTokenToServer(token);
      }
      _messaging.onTokenRefresh.listen(_registerTokenToServer);
    }
  }

  Future<void> _registerTokenToServer(String fcmToken) async {
    try {
      final accessToken = await SharedPrefs.fetchAccessToken();
      if (accessToken == null) return;

      final deviceType = Platform.isIOS ? 'ios' : 'android';
      await http.post(
        Uri.parse('${baseUri}attendances/fcm-token/register/?token=$accessToken'),
        headers: {
          'Authorization': 'JWT $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': fcmToken,
          'device_type': deviceType,
        }),
      );
    } catch (e) {
      print('FCM token registration error: $e');
    }
  }

  Future<void> unregisterToken() async {
    try {
      final accessToken = await SharedPrefs.fetchAccessToken();
      if (accessToken == null) return;

      final fcmToken = await _messaging.getToken();
      await http.post(
        Uri.parse('${baseUri}attendances/fcm-token/unregister/?token=$accessToken'),
        headers: {
          'Authorization': 'JWT $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'token': fcmToken}),
      );
    } catch (e) {
      print('FCM token unregister error: $e');
    }
  }
}
