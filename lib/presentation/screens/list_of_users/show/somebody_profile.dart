// ignore_for_file: must_be_immutable, unnecessary_string_escapes, non_constant_identifier_names, use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wbrs/app/helper/global.dart';
import 'package:wbrs/app/helper/helper_function.dart';
import 'package:wbrs/presentation/screens/chat_screen/chatscreen.dart';
import 'package:wbrs/presentation/screens/home/home_page.dart';
import 'package:wbrs/presentation/screens/shop/shop.dart';
import 'package:wbrs/app/widgets/fullscreen_image_slider.dart';
import 'package:wbrs/service/database_service.dart';
import 'package:wbrs/app/widgets/widgets.dart';

import '../../../../service/notifications.dart';
import '../../../../app/widgets/bottom_nav_bar.dart';

class SomebodyProfile extends StatefulWidget {
  String uid;
  String photoUrl;
  String name;
  Map userInfo;
  SomebodyProfile(
      {super.key,
      required this.uid,
      required this.photoUrl,
      required this.name,
      required this.userInfo});

  @override
  State<SomebodyProfile> createState() => _SomebodyProfileState();
}

class _SomebodyProfileState extends State<SomebodyProfile> {
  FirebaseFirestore db = firebaseFirestore;
  CollectionReference users = firebaseFirestore.collection('users');
  bool isLoading = true;
  getChatRoomIdByUsernames(String a, String b) {
    if (a.isNotEmpty && b.isNotEmpty) {
      if (a.substring(0, 1).codeUnitAt(0) <= b.substring(0, 1).codeUnitAt(0)) {
        return '$a\_$b';
      } else {
        return '$b\_$a';
      }
    } else {
      return 'abrakadabra';
    }
  }

  notifyVisiter(userInfo) async {
    String token = '';
    var data =
    await firebaseFirestore.collection('TOKENS').doc(widget.uid).get();
    token = data.get('token');
    Map notification = {
      'isChat': false,
      'chatId': userInfo['uid'],
      'message':
      '${firebaseAuth.currentUser!.displayName} посетил/а ваш профиль',
    };
    print(token);
    NotificationsService()
        .sendPushMessageGroup(token, notification, userInfo['fullName'], 1, userInfo['uid']);
  }

  upgradeUserVisiters(String uid) async {
    setState(() {
      isLoading = false;
    });
    String myUid = firebaseAuth.currentUser!.uid;

    var doc = await db
        .collection('users')
        .doc(uid)
        .collection('visiters')
        .doc(myUid)
        .get();

    var MyUserInfo =
        await db.collection('users').doc(firebaseAuth.currentUser!.uid).get();

    if (!MyUserInfo.data()!['isUnVisible']) {
      if (!doc.exists) {
        firebaseFirestore
            .collection('users')
            .doc(uid)
            .collection('visiters')
            .doc(myUid)
            .set({
          'uid': myUid,
          'photoUrl': firebaseAuth.currentUser!.photoURL,
          'lastVisitTs': DateTime.now(),
          'fullName': firebaseAuth.currentUser!.displayName,
          'age': MyUserInfo.get('age'),
          'group': MyUserInfo.get('группа'),
          'city': MyUserInfo.get('city')
        });
      } else {
        db
            .collection('users')
            .doc(uid)
            .collection('visiters')
            .doc(myUid)
            .update({
          'photoUrl': firebaseAuth.currentUser!.photoURL,
          'lastVisitTs': DateTime.now(),
          'fullName': firebaseAuth.currentUser!.displayName,
          'age': MyUserInfo.get('age'),
          'city': MyUserInfo.get('city')
        });
      }
      debugPrint('visiters updated');
      notifyVisiter(MyUserInfo.data()!);
    }
  }

  List images = [];

  getImages() async {
    var res =
        await db.collection('users').doc(widget.uid).collection('images').get();
    images = res.docs.map((e) {
      try {
        return e.get('url');
      } catch (e) {
        return null;
      }
    }).where((element) => (element != null && element != '')).toList();
    images.add(widget.photoUrl);
    debugPrint(images.toString());
    setState(() {
      images.sort(
        (a, b) {
          return a.toString().contains('avatar')
              ? -1
              : b.toString().contains('avatar')
                  ? 1
                  : 0;
        },
      );
    });
  }

  @override
  void initState() {
    upgradeUserVisiters(widget.uid);
    setState(() {
      isLoading = true;
    });
    getImages();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    images.clear();
  }

  @override
  Widget build(BuildContext context) {
    bool HaveOrNot = false;

    BuildSomebodyProfile() {
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
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                backgroundColor: Colors.transparent,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    TextButton(
                      onPressed: () {
                        showSnackbar(context, Colors.green,
                            'Спасибо за отклик! Мы уже рассматриваем заявку.');
                      },
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info,
                            size: 30,
                            color: Colors.red,
                          ),
                          Text(
                            ' Пожаловаться',
                            style: TextStyle(color: Colors.redAccent),
                          )
                        ],
                      ),
                    ),
                  ],
                )),
            body: isLoading
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 17),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (widget.photoUrl != '') {
                                  int index = 0;
                                  for (var element in images) {
                                    if (element == widget.photoUrl) {
                                      index = images.indexOf(element);
                                    }
                                  }
                                  openImage(index, images);
                                }
                              },
                              child: userImageWithCircle(
                                  (widget.photoUrl != '')
                                      ? widget.photoUrl
                                      : '',
                                  widget.userInfo['группа'],
                                  false,
                                  100.0,
                                  100.0),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: statusRow(
                                  widget.userInfo.containsKey('online')
                                      ? widget.userInfo['online']
                                      : false,
                                  widget.userInfo.containsKey('lastOnlineTS')
                                      ? widget.userInfo['lastOnlineTS'].toDate()
                                      : DateTime.now()
                                          .subtract(const Duration(minutes: 5)),
                                  widget.userInfo['pol']),
                            ),
                            Center(
                              child: TextButton(
                                onPressed: () async {
                                  Map<String, dynamic> chatRoomInfoMap = {
                                    'user1': FirebaseAuth
                                        .instance.currentUser!.uid
                                        .toString(),
                                    'user2': widget.uid,
                                    'user1Nickname': FirebaseAuth
                                        .instance.currentUser!.displayName,
                                    'user2Nickname': widget.name,
                                    'user1_image': FirebaseAuth
                                        .instance.currentUser!.photoURL,
                                    'user2_image': widget.photoUrl,
                                    'lastMessage': '',
                                    'lastMessageSendBy': '',
                                    'lastMessageSendTs': DateTime.now(),
                                    'unreadMessage': 0,
                                    'chatId': getChatRoomIdByUsernames(
                                        FirebaseAuth
                                            .instance.currentUser!.displayName
                                            .toString(),
                                        widget.name)
                                  };
                                  await firebaseFirestore
                                      .collection('chats')
                                      .where('user1',
                                          isEqualTo: FirebaseAuth
                                              .instance.currentUser!.uid)
                                      .where('user2', isEqualTo: widget.uid)
                                      .get()
                                      .then((QuerySnapshot snapshot) {
                                    if (snapshot.docs.isEmpty) {
                                    } else {
                                      HaveOrNot = true;
                                    }
                                  });
                                  await firebaseFirestore
                                      .collection('chats')
                                      .where('user2',
                                          isEqualTo: FirebaseAuth
                                              .instance.currentUser!.uid)
                                      .where('user1', isEqualTo: widget.uid)
                                      .get()
                                      .then((QuerySnapshot snapshot) {
                                    if (snapshot.docs.isEmpty) {
                                    } else {
                                      HaveOrNot = true;
                                    }
                                  });
                                  await firebaseFirestore
                                      .collection('chats')
                                      .where('chatId',
                                          isEqualTo: getChatRoomIdByUsernames(
                                              firebaseAuth
                                                  .currentUser!.displayName
                                                  .toString(),
                                              widget.name))
                                      .get()
                                      .then((QuerySnapshot snapshot) {
                                    if (snapshot.docs.isEmpty) {
                                    } else {
                                      HaveOrNot = true;
                                    }
                                    if (HaveOrNot == false) {
                                      DatabaseService().createChatRoom(
                                          getChatRoomIdByUsernames(
                                              firebaseAuth
                                                  .currentUser!.displayName
                                                  .toString(),
                                              widget.name),
                                          chatRoomInfoMap);
                                      DatabaseService().addChat(
                                          FirebaseAuth
                                              .instance.currentUser!.uid,
                                          getChatRoomIdByUsernames(
                                              firebaseAuth
                                                  .currentUser!.displayName
                                                  .toString(),
                                              widget.name));
                                      DatabaseService().addChatSecondUser(
                                          widget.uid,
                                          getChatRoomIdByUsernames(
                                              firebaseAuth
                                                  .currentUser!.displayName
                                                  .toString(),
                                              widget.name));
                                      nextScreenReplace(
                                          context, const ShopPage());
                                    } else {
                                      nextScreenReplace(
                                          context, const ShopPage());
                                    }
                                  });
                                  setState(() {
                                    selectedIndex = 1;
                                  });
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.card_giftcard,
                                      size: 30,
                                      color: Colors.orangeAccent,
                                    ),
                                    Text(
                                      'Подарить подарок',
                                      textAlign: TextAlign.center,
                                      style:
                                          TextStyle(color: Colors.orangeAccent),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0)),
                            images.isEmpty
                                ? const Text(
                                    'Нет фотографий',
                                    style: TextStyle(color: Colors.white),
                                  )
                                : SizedBox(
                                    height:
                                        MediaQuery.of(context).size.width / 2,
                                    width: MediaQuery.of(context).size.width,
                                    child: CarouselSlider(
                                        items: images
                                            .map((item) => GestureDetector(
                                                  onTap: () {
                                                    int initPage =
                                                        images.indexOf(item);
                                                    nextScreen(
                                                        context,
                                                        FullscreenSliderDemo(
                                                            imgList: images,
                                                            initialPage:
                                                                initPage));
                                                  },
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: CachedNetworkImage(
                                                      imageUrl: item,
                                                      fit: BoxFit.cover,
                                                      width: 250,
                                                      height: 250,
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                        options: CarouselOptions(
                                            enableInfiniteScroll: false)),
                                  ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal),
                                ),
                                TextButton(
                                    onPressed: () async {
                                      String chatID = '';
                                      Map<String, dynamic> chatRoomInfoMap = {
                                        'user1': FirebaseAuth
                                            .instance.currentUser!.uid
                                            .toString(),
                                        'user2': widget.uid,
                                        'user1Nickname': FirebaseAuth
                                            .instance.currentUser!.displayName,
                                        'user2Nickname': widget.name,
                                        'user1_image': FirebaseAuth
                                            .instance.currentUser!.photoURL,
                                        'user2_image': widget.photoUrl,
                                        'lastMessage': '',
                                        'lastMessageSendBy': '',
                                        'lastMessageSendTs': DateTime.now(),
                                        'unreadMessage': 0,
                                        'chatId': getChatRoomIdByUsernames(
                                            firebaseAuth
                                                .currentUser!.displayName
                                                .toString(),
                                            widget.name)
                                      };
                                      await firebaseFirestore
                                          .collection('chats')
                                          .where('user1',
                                              isEqualTo: FirebaseAuth
                                                  .instance.currentUser!.uid)
                                          .where('user2', isEqualTo: widget.uid)
                                          .get()
                                          .then((QuerySnapshot snapshot) {
                                        if (snapshot.docs.isEmpty) {
                                        } else {
                                          HaveOrNot = true;
                                          chatID = snapshot.docs[0].id;
                                        }
                                      });
                                      await firebaseFirestore
                                          .collection('chats')
                                          .where('user2',
                                              isEqualTo: FirebaseAuth
                                                  .instance.currentUser!.uid)
                                          .where('user1', isEqualTo: widget.uid)
                                          .get()
                                          .then((QuerySnapshot snapshot) {
                                        if (snapshot.docs.isEmpty) {
                                        } else {
                                          HaveOrNot = true;
                                          chatID = snapshot.docs[0].id;
                                        }
                                      });
                                      await firebaseFirestore
                                          .collection('chats')
                                          .where('chatId',
                                              isEqualTo:
                                                  getChatRoomIdByUsernames(
                                                      FirebaseAuth
                                                          .instance
                                                          .currentUser!
                                                          .displayName
                                                          .toString(),
                                                      widget.name))
                                          .get()
                                          .then((QuerySnapshot snapshot) {
                                        if (snapshot.docs.isEmpty) {
                                        } else {
                                          HaveOrNot = true;
                                        }
                                        if (HaveOrNot == false) {
                                          DatabaseService().createChatRoom(
                                              getChatRoomIdByUsernames(
                                                  firebaseAuth
                                                      .currentUser!.displayName
                                                      .toString(),
                                                  widget.name),
                                              chatRoomInfoMap);
                                          DatabaseService().addChat(
                                              FirebaseAuth
                                                  .instance.currentUser!.uid,
                                              getChatRoomIdByUsernames(
                                                  firebaseAuth
                                                      .currentUser!.displayName
                                                      .toString(),
                                                  widget.name));
                                          DatabaseService().addChatSecondUser(
                                              widget.uid,
                                              getChatRoomIdByUsernames(
                                                  firebaseAuth
                                                      .currentUser!.displayName
                                                      .toString(),
                                                  widget.name));
                                          nextScreenReplace(
                                              context, const HomePage());
                                        } else {
                                          nextScreenReplace(
                                              context,
                                              ChatScreen(
                                                chatId: chatID,
                                                chatWithUsername: widget.name,
                                                id: FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                photoUrl: widget.photoUrl,
                                              ));
                                        }
                                      });
                                      setState(() {
                                        selectedIndex = 1;
                                      });
                                    },
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(
                                          Icons.messenger_outline,
                                          color: Colors.orange,
                                          size: 30,
                                        ),
                                      ],
                                    ))
                              ],
                            ),
                            Column(
                              children: [
                                if ([
                                  'T4zb6OLzDgMh0qrfp3eEahNKmNl1',
                                  'lyNcv2xr33Ms6G9fI0bhBEcDKFj2',
                                  'vLeB8v4b1pUL8h5dtxJSkifF2v72'
                                ].contains(firebaseAuth.currentUser!.uid))
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Почта: ',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      GestureDetector(
                                        onLongPress: () {
                                          Clipboard.setData(ClipboardData(
                                                  text:
                                                      widget.userInfo['email']))
                                              .then((value) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Почта скопирована в буфер обмена.'),
                                              ),
                                            );
                                          });
                                        },
                                        child: Text(
                                          widget.userInfo['email'].toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 17),
                                        ),
                                      )
                                    ],
                                  ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Возраст: ',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      widget.userInfo['age'].toString(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 17),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Рост: ',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      widget.userInfo['rost'],
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 17),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Хобби: ',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                      softWrap: true,
                                      textAlign: TextAlign.left,
                                    ),
                                    Flexible(
                                      child: Text(
                                        widget.userInfo['hobbi'] != ''
                                            ? widget.userInfo['hobbi']
                                            : 'не заполнено',
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 17),
                                        softWrap: true,
                                        maxLines: 10,
                                        overflow: TextOverflow.fade,
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Дети: ',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      widget.userInfo['deti'] ? 'есть' : 'нет',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 17),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Группа: ',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Flexible(
                                      child: Text(
                                        widget.userInfo['группа'],
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 17),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Города: ',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      widget.userInfo['city'],
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 17),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('О себе',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                        textAlign: TextAlign.left),
                                    const Padding(
                                        padding: EdgeInsets.only(bottom: 18.0)),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          child: Text(
                                            widget.userInfo['about'],
                                            style: const TextStyle(
                                                fontSize: 17,
                                                color: Colors.white),
                                            textAlign: TextAlign.center,
                                            softWrap: true,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                : const CircularProgressIndicator.adaptive(),
          ),
        ],
      );
    }

    return BuildSomebodyProfile();

    //);
  }

  openImage(index, urls) {
    showDialog(
      builder: (context) => AlertDialog(
        iconPadding:
            EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.8),
        iconColor: Colors.white,
        contentPadding: const EdgeInsets.all(0),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.black,
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
                image: NetworkImage(
                  urls[index],
                ),
                fit: BoxFit.fitHeight),
          ),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {
                    if (index != 0) {
                      Navigator.pop(context);
                      openImage(index - 1, urls);
                    }
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: index == 0 ? Colors.grey : Colors.white,
                  )),
              IconButton(
                  onPressed: () {
                    if (index != urls.length - 1) {
                      Navigator.pop(context);
                      openImage(index + 1, urls);
                    }
                  },
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color:
                        index == urls.length - 1 ? Colors.grey : Colors.white,
                  )),
            ],
          ),
        ),
      ),
      context: context,
    );
  }
}
