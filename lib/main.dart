// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:wbrs/app/helper/helper_function.dart';
import 'package:wbrs/presentation/screens/auth/login_screen/login_page.dart';
import 'package:wbrs/presentation/screens/home/home_page.dart';
import 'package:wbrs/presentation/screens/profile/profile_page.dart';
import 'package:wbrs/presentation/screens/test/red_group.dart';
import 'package:wbrs/shared/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wbrs/app/widgets/splash.dart';
import 'package:wbrs/app/widgets/widgets.dart';

import 'presentation/screens/list_of_meets/show/about_meet.dart';
import 'presentation/screens/chat_screen/chatscreen.dart';
import 'firebase_options.dart';
import 'app/helper/global.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling a background message ${message.messageId}');
}

listenNotify(context) async {
  const AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      message.notification!.body.toString(),
      htmlFormatBigText: true,
      contentTitle: message.notification!.title.toString(),
      htmlFormatContentTitle: true,
    );

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('wbrs', 'wbrs',
            importance: Importance.max,
            styleInformation: bigTextStyleInformation,
            priority: Priority.max,
            playSound: true);

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidNotificationDetails);

    try {
      await flutterLocalNotificationsPlugin.show(0, message.notification?.title,
          message.notification?.body, platformChannelSpecifics,
          payload: message.notification!.body);
    } on Exception catch (e) {
      showSnackbar(context, Colors.red, e);
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    Map body = jsonDecode(message.data['payload']);
    if (body['isChat'] == true) {
      nextScreenReplace(
          context,
          ChatScreen(
            chatWithUsername: body['chatWith'],
            photoUrl: body['photoUrl'],
            id: body['id'],
            chatId: body['chatId'],
          ));
    } else {
      body['users'] =
          body['users'].toString().replaceAll('[', '').replaceAll(']', '');
      List users = body['users'].toString().split(',');
      nextScreenReplace(
          context,
          AboutMeet(
            id: body['groupId'],
            users: users,
            name: body['groupName'],
            is_user_join: body['isUserJoin'].toString() == 'true',
          ));
    }
  });
}

migrate() {
  firebaseFirestore.collection('users').get().then((value) {
    for (var element in value.docs) {
      firebaseFirestore
          .collection('users')
          .doc(element.id)
          .update({'chatWithId': ''});
    }
  });
}

void main() async {
  late final FirebaseApp app;
  WidgetsFlutterBinding.ensureInitialized();

  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance
        .recordError(details.exceptionAsString(), details.stack, fatal: true);
  };
  FirebaseAuth.instanceFor(app: app);
  await SharedPreferences.getInstance();
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _isSignedIn = false;
  bool _isRegistrationEnd = false;
  bool _loading = true;
  bool _hasInternet = true;

  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  late AndroidNotificationChannel channel;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ignore: prefer_typing_uninitialized_variables
  var doc;

  updateUserStatus(value) async {
    if(!_isRegistrationEnd) return;
    await firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .update({'online': value});
    if (!value) {
      await firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .update({'lastOnlineTS': DateTime.now()});
    }
  }

  @override
  void dispose() {
    //WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(_isRegistrationEnd);
    if (state != AppLifecycleState.resumed) {
      updateUserStatus(false);
    } else {
      updateUserStatus(true);
    }
  }

  initFunction() async {
    await checkInternet();
    selectedIndex = 1;
    await getUserLoggedInStatus();
    if (_isSignedIn) {
      updateUserStatus(true);
      getUserInfo();
      getUserRegistrationStatus();
    }
    firebaseMessaging.requestPermission();
  }

  @override
  void initState() {
    super.initState();
    initFunction();
    listenNotify(context);
    WidgetsBinding.instance.addObserver(this);
  }

  initNotify() {
    const AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContentTitle: true,
      );

      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails('wbrs', 'wbrs',
              importance: Importance.max,
              styleInformation: bigTextStyleInformation,
              priority: Priority.max,
              playSound: true);

      NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidNotificationDetails);

      try {
        await flutterLocalNotificationsPlugin.show(
            0,
            message.notification?.title,
            message.notification?.body,
            platformChannelSpecifics,
            payload: message.notification?.body);
      } on Exception catch (e) {
        showSnackbar(context, Colors.red, e);
      }
    });
    firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .update(
      {
        'chatWithId': '',
      },
    );
  }

  Future<String> getAndroidVersion() async {
    const channel = MethodChannel('app_info');
    try {
      final version = await channel.invokeMethod('getVersion');
      return version as String;
    } catch (e) {
      return 'N/A';
    }
  }

  getUserInfo() async {
    doc = await firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .get();

    globalBalance = doc.get('balance');
    group = doc.get('группа');
    initNotify();
  }

  checkInternet() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      setState(() {
        _hasInternet = false;
        print(_hasInternet);
      });
      return false;
    }
  }

  getUserLoggedInStatus() async {
    if (firebaseAuth.currentUser != null) {
      DocumentSnapshot data = await firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .get();

      if (data.exists) {
        if (data.get('status') == 'blocked') {
          showSnackbar(context, Colors.red, 'Ваш аккаунт заблокирован');
          await firebaseAuth.signOut();
          nextScreenReplace(context, const LoginPage());
        }
      } else {
        if(firebaseAuth.currentUser != null){
          await firebaseAuth.currentUser!.delete();
        }
        showSnackbar(context, Colors.red, 'Ваш аккаунт удален');
        nextScreenReplace(context, const LoginPage());
      }
    }
    await HelperFunctions.getUserLoggedInStatus().then((value) {
      if (value != null) {
        setState(() {
          _isSignedIn = value;
          if(firebaseAuth.currentUser == null){
            _isSignedIn = false;
          }
        });
      }
    });
  }

  getUserRegistrationStatus() async {
    var collection = await firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .get();

    if(collection.data()!.containsKey('isRegistrationEnd')){
      _isRegistrationEnd = await collection.get('isRegistrationEnd');

      if (_isRegistrationEnd) {
        setState(() {
          _loading = false;
        });
      }
    } else{
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme tema = GoogleFonts.latoTextTheme(Theme.of(context).textTheme);
    return LayoutBuilder(builder: (context, constraints) {
      return OrientationBuilder(builder: (context, orientation) {
        return Sizer(builder: (context, orientation, deviceType) {
          // return MaterialApp.router(
          //   routerConfig: router,
          // );
          return MaterialApp(
            theme: ThemeData(
                fontFamily: 'Roboto',
                primaryColor: Constants().primaryColor,
                scaffoldBackgroundColor: Colors.white,
                textTheme: tema),
            debugShowCheckedModeBanner: false,
            routes: {
              'profile': (context) {
                return ProfilePage(
                  group: getUserGroup(),
                  email: firebaseAuth.currentUser!.email.toString(),
                  userName: firebaseAuth.currentUser!.displayName.toString(),
                  about: doc.get('about'),
                  age: doc.get('age').toString(),
                  rost: doc.get('rost'),
                  hobbi: doc.get('hobbi'),
                  city: doc.get('city'),
                  deti: doc.get('deti'),
                  pol: doc.get('pol'),
                );
              }
            },
            home: _isSignedIn
                ? _loading
                ? const SplashScreen()
                : _isRegistrationEnd
                ? const HomePage()
                : const FirstGroupRed()
                : const LoginPage()
          );
        });
      });
    });
  }
}
