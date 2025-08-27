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
<<<<<<< Updated upstream
import 'package:wbrs/app/widgets/splash.dart';
import 'package:wbrs/app/widgets/widgets.dart';
=======
import 'package:messenger/widgets/check_internet.dart';
import 'package:messenger/widgets/widgets.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes

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

<<<<<<< Updated upstream
<<<<<<< Updated upstream
  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance
        .recordError(details.exceptionAsString(), details.stack, fatal: true);
  };
  FirebaseAuth.instanceFor(app: app);
  await SharedPreferences.getInstance();
=======
=======
>>>>>>> Stashed changes
  // Crashlytics setup
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
<<<<<<< Updated upstream
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _isSignedIn = false;
=======
class _MyAppState extends State<MyApp> {
>>>>>>> Stashed changes
=======
class _MyAppState extends State<MyApp> {
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
<<<<<<< Updated upstream
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
=======
=======
>>>>>>> Stashed changes
    selectedIndex = 1;
    checkInternet();
    if (Platform.isIOS) {
      firebaseMessaging.requestPermission();
    }
  }

  Future<void> loadUserDoc() async {
    if (FirebaseAuth.instance.currentUser == null) return;
    try {
      doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          _isRegistrationEnd = doc.get('isRegistrationEnd') ?? true;
        });
      }
    } catch (e, st) {
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'loadUserDoc');
    }
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
  }

  checkInternet() async {
    try {
<<<<<<< Updated upstream
<<<<<<< Updated upstream
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
=======
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        if (mounted) {
          nextScreen(context, const CheckInternetPage());
        }
        return false;
      }
      return true;
    } catch (e, st) {
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'checkInternet');
      return true;
    }
  }

=======
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        if (mounted) {
          nextScreen(context, const CheckInternetPage());
        }
        return false;
      }
      return true;
    } catch (e, st) {
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'checkInternet');
      return true;
    }
  }

>>>>>>> Stashed changes
  @override
  Widget build(BuildContext context) {
    TextTheme tema = GoogleFonts.robotoTextTheme(Theme.of(context).textTheme);
    return MaterialApp(
      theme: ThemeData(
          fontFamily: 'Times New Roman',
          primaryColor: Constants().primaryColor,
          scaffoldBackgroundColor: Colors.white,
          textTheme: tema),
      debugShowCheckedModeBanner: false,
      routes: {
        'profile': (context) {
          if (doc == null || !doc.exists) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return ProfilePage(
            group: getUserGroup(),
            email: FirebaseAuth.instance.currentUser!.email.toString(),
            userName: FirebaseAuth.instance.currentUser!.displayName.toString(),
            about: doc.get('about') ?? '',
            age: doc.get('age')?.toString() ?? '0',
            rost: doc.get('rost') ?? '',
            hobbi: doc.get('hobbi') ?? '',
            city: doc.get('city') ?? '',
            deti: doc.get('deti') ?? false,
            pol: doc.get('pol') ?? '',
          );
        }
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (snapshot.connectionState == ConnectionState.active) {
            if (user == null) {
              return const LoginPage();
            } else {
              // after sign-in, ensure we have latest user doc data
              return FutureBuilder(
                future: loadUserDoc(),
                builder: (context, snap) {
                  return const HomePage();
                },
              );
            }
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  void loadFCM() async {
    if (!kIsWeb) {
      var channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications',
        'High Importance Notifications', // title
        importance: Importance.high,
        enableVibration: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (!mounted) return;
      
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        try {
          await flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: 'launch_background',
              ),
            ),
          );
        } catch (e, st) {
          FirebaseCrashlytics.instance.recordError(e, st, reason: 'listenFCM');
        }
      }
>>>>>>> Stashed changes
    });
  }
}
