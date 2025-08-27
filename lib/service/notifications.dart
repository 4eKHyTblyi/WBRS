// ignore_for_file: empty_catches, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' as s;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class NotificationsService {
  void sendPushMessage(
      String token, Map body, String title, unreadMsgCount, chatRoomId) async {
    try {
      var resp = await getAccessToken();
      var res = await http.post(
          Uri.parse(
              'https://fcm.googleapis.com/v1/projects/chatapp-4e347/messages:send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $resp'
          },
          body: jsonEncode(<String, dynamic>{
            'message': <String, dynamic>{
              'token': token,
              'data': <String, dynamic>{
                'android_channel_id': 'wbrs',
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'status': 'done',
                'icon': '@mipmap/ic_launcher',
                'sound': 'default',
                'payload': jsonEncode(body),
                'unreadMsgCount': unreadMsgCount.toString(),
              },
              'notification': <String, dynamic>{
                'title': title,
                'body': body['message'],
              },
            }
          }));

      if (res.statusCode == 200) {
        debugPrint('Уведомление успешно отправлено');
      } else {
        FirebaseCrashlytics.instance.recordError(
          'FCM notification failed',
          StackTrace.current,
          reason: 'Ошибка API FCM',
          information: ['код_статуса: ${res.statusCode}', 'ответ: ${res.body}'],
        );
        debugPrint('Ошибка при отправке уведомления: ${res.statusCode}');
        debugPrint(res.body);
      }
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Ошибка отправки push-уведомления',
        information: ['токен: $token', 'id_чата: $chatRoomId'],
      );
      debugPrint(e.toString());
    }
  }

  void sendPushMessageGroup(
      String token, Map body, String title, unreadMsgCount, groupRoomId) async {
    try {
      var resp = await getAccessToken();
      var res = await http.post(
          Uri.parse(
              'https://fcm.googleapis.com/v1/projects/chatapp-4e347/messages:send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $resp'
          },
          body: jsonEncode(<String, dynamic>{
            'message': <String, dynamic>{
              'token': token,
              'data': <String, dynamic>{
                'android_channel_id': 'wbrs',
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'status': 'done',
                'icon': '@mipmap/ic_launcher',
                'sound': 'default',
                'priority': 'high',
                'time_to_live': '86400',
                'payload': jsonEncode(body),
              },
              'notification': <String, dynamic>{
                'title': title,
                'body': body['message'],
              },
            }
          }));
      if (res.statusCode == 200) {
        debugPrint('Уведомление успешно отправлено');
      } else {
        FirebaseCrashlytics.instance.recordError(
          'FCM group notification failed',
          StackTrace.current,
          reason: 'Ошибка API FCM для группы',
          information: ['код_статуса: ${res.statusCode}', 'ответ: ${res.body}'],
        );
        debugPrint('Ошибка при отправке уведомления: ${res.statusCode}');
        debugPrint(res.body);
      }
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Ошибка отправки группового push-уведомления',
        information: ['токен: $token', 'id_группы: $groupRoomId'],
      );
      debugPrint(e.toString());
    }
  }
}

const List<String> _scopes = [
  'https://www.googleapis.com/auth/firebase.messaging',
];

Future getAccessToken() async {
  try {
    final serviceAccountJson =
        json.decode(await s.rootBundle.loadString('assets/credentials.json'));
    final credentials = ServiceAccountCredentials.fromJson(serviceAccountJson);
    final client = await clientViaServiceAccount(credentials, _scopes);

    return client.credentials.accessToken.data;
  } catch (e) {
    FirebaseCrashlytics.instance.recordError(
      e,
      StackTrace.current,
      reason: 'Ошибка получения токена доступа',
    );
    rethrow;
  }
}
