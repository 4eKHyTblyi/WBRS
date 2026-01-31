import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wbrs/app/helper/global.dart';
import 'package:wbrs/service/auth_service.dart';
import 'package:wbrs/app/widgets/chat_room_list.dart';
import 'package:wbrs/app/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wbrs/app/widgets/widgets.dart';
import '../../../app/widgets/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthService authService = AuthService();

  @override
  void initState() {
    requestPermission();
    getToken();
    initInfo();
    firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .update({'online': true});
    firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .update({'lastOnlineTS': DateTime.now()});
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  initInfo() {}

  void saveUserToken(String token) {
    firebaseFirestore
        .collection('TOKENS')
        .doc(firebaseAuth.currentUser?.uid)
        .set({'token': token});
  }

  void requestPermission() async {
    try {
      NotificationSettings settings = await firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
      } else {}
    } on Exception catch (e) {
      if (mounted) {
        showSnackbar(context, Colors.red, e);
      }
      firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .update({'token': e});
    }
  }

  String? mtoken;
  void getToken() async {
    await FirebaseFirestore.instance
        .collection('TOKENS')
        .doc(firebaseAuth.currentUser?.uid)
        .get()
        .then((value) {
          setState(() {
            mtoken = value['token'];
          });
        });
    if (mtoken != null) {
      return;
    }

    await firebaseMessaging.getToken().then((token) {
      mtoken = token;
    });

    saveUserToken(mtoken!);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/fon.jpg',
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          bottomNavigationBar: const MyBottomNavigationBar(),
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            title: const Text(
              'Чаты',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 27,
              ),
            ),
            actions: [
              Text(
                'Ваш баланс:\n ${globalBalance.toString()} серебра\n на подарки',
                style: TextStyle(color: Colors.white, height: 1.1),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          drawer: const MyDrawer(),
          body: SizedBox(
            height: 10000,
            child: StreamBuilder(
              stream: firebaseFirestore
                  .collection('chats')
                  .where(
                    Filter.or(
                      Filter('user1', isEqualTo: firebaseAuth.currentUser!.uid),
                      Filter('user2', isEqualTo: firebaseAuth.currentUser!.uid),
                    ),
                  )
                  .snapshots(),
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      if (!snapshot.hasData) {
                        return const Text(
                          'Нет чатов',
                          textAlign: TextAlign.center,
                        );
                      } else {
                        List sortedList = snapshot.data!.docs;
                        sortedList.sort((a, b) {
                          return b
                              .get('lastMessageSendTs')
                              .compareTo(a.get('lastMessageSendTs'));
                        });
                        if (firebaseAuth.currentUser != null) {
                          return ListView.builder(
                            itemCount: sortedList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 7.0,
                                  horizontal: 15,
                                ),
                                child: SizedBox(
                                  height: 100,
                                  child: ChatRoomList(
                                    snapshot: sortedList[index],
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return const Text('none');
                        }
                      }
                    }
                  },
            ),
          ),
        ),
      ],
    );
  }
}
