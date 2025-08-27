// ignore_for_file: must_be_immutable, unnecessary_string_escapes, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messenger/helper/global.dart';
import 'package:messenger/pages/chatscreen.dart';
import 'package:messenger/pages/home_page.dart';
import 'package:messenger/service/database_service.dart';
import 'package:messenger/widgets/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../../widgets/bottom_nav_bar.dart';

class SomebodyProfile extends StatefulWidget {
  String uid;
  String photoUrl;
  String name;
  DocumentSnapshot userInfo;
  SomebodyProfile(
      {Key? key,
      required this.uid,
      required this.photoUrl,
      required this.name,
      required this.userInfo})
      : super(key: key);

  @override
  State<SomebodyProfile> createState() => _SomebodyProfileState();
}

class _SomebodyProfileState extends State<SomebodyProfile> {
  CollectionReference users = FirebaseFirestore.instance.collection("users");
  bool isLoading = true;
  getChatRoomIdByUsernames(String a, String b) {
    if (a.isNotEmpty && b.isNotEmpty) {
      if (a.substring(0, 1).codeUnitAt(0) <= b.substring(0, 1).codeUnitAt(0)) {
        return "$a\_$b";
      } else {
        return "$b\_$a";
      }
    } else {
      return "abrakadabra";
    }
  }

  upgradeUserVisiters(String uid) async {
    try {
      setState(() {
        isLoading = false;
      });
      String myUid = FirebaseAuth.instance.currentUser!.uid;

      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('visiters')
          .doc(myUid)
          .get();

      var MyUserInfo = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (!doc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('visiters')
            .doc(myUid)
            .set({
          "uid": myUid,
          "photoUrl": FirebaseAuth.instance.currentUser!.photoURL ?? '',
          "lastVisitTs": DateTime.now(),
          "fullName": FirebaseAuth.instance.currentUser!.displayName ?? '',
          "age": MyUserInfo.get('age') ?? 0,
          "city": MyUserInfo.get('city') ?? ''
        });
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('visiters')
            .doc(myUid)
            .update({
          "photoUrl": FirebaseAuth.instance.currentUser!.photoURL ?? '',
          "lastVisitTs": DateTime.now(),
          "fullName": FirebaseAuth.instance.currentUser!.displayName ?? '',
          "age": MyUserInfo.get('age') ?? 0,
          "city": MyUserInfo.get('city') ?? ''
        });
      }
    } catch (e, st) {
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'upgradeUserVisiters');
    }
  }

  List images = [];
  String _profilePic = "";

  getUserInfo() async {
    try {
      images = widget.userInfo.get('images') ?? [];
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
      if (doc.exists) {
        _profilePic = (doc.data() ?? const {})['profilePic'] ?? widget.photoUrl;
      } else {
        _profilePic = widget.photoUrl;
      }
    } catch (e, st) {
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'getUserInfo');
      _profilePic = widget.photoUrl;
    }
  }

  @override
  void initState() {
    super.initState();

    getUserInfo();
    upgradeUserVisiters(widget.uid);
    setState(() {
      isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool HaveOrNot = false;

    // Future NicknameOfUid(String uid) async {
    //   dynamic nickname;
    //   await FirebaseFirestore.instance.collection("users").doc(uid).get().then((doc) {
    //     nickname=doc['fullName'];
    //     photoUrl=doc['profilePic'];
    //
    //   });
    //   nickName=nickname;
    //   return nickname;
    //
    // }

    BuildSomebodyProfile() {
      return Stack(
        children: [
          Image.asset(
            "assets/fon.jpg",
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          Scaffold(
            bottomNavigationBar: const MyBottomNavigationBar(),
            backgroundColor: Colors.transparent,
            appBar: AppBar(
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
                            "Спасибо за отклик! Мы уже рассматриваем заявку.");
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
                            (_profilePic == "" || _profilePic.isEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(100.0),
                                    child: Image.asset(
                                      "assets/profile.png",
                                      fit: BoxFit.cover,
                                      height: 150.0,
                                      width: 150.0,
                                    ))
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(100.0),
                                    child: CachedNetworkImage(
                                      imageUrl: _profilePic,
                                      fit: BoxFit.cover,
                                      height: 150.0,
                                      width: 150.0,
                                      cacheKey: 'profile-${widget.uid}',
                                      placeholder: (context, url) => const SizedBox.shrink(),
                                      errorWidget: (context, url, error) => Image.asset("assets/profile.png"),
                                    )),
                            const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0)),
                            images.isEmpty
                                ? const Text(
                                    "Нет фотографий",
                                    style: TextStyle(color: Colors.white),
                                  )
                                : SizedBox(
                                    height: 100,
                                    width: MediaQuery.of(context).size.width,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (BuildContext BuildContext,
                                          int index) {
                                        return Container(
                                          decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  bottomLeft:
                                                      Radius.circular(15))),
                                          height: 300,
                                          child: InkWell(
                                              onTap: () {
                                                showDialog(
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    insetPadding:
                                                        const EdgeInsets.all(2),
                                                    title: Container(
                                                      decoration:
                                                          const BoxDecoration(),
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: CachedNetworkImage(
                                                        imageUrl: widget.userInfo
                                                            .get('images')[index],
                                                        cacheKey: 'gallery-${widget.uid}-$index',
                                                      ),
                                                    ),
                                                  ),
                                                  context: context,
                                                );
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    right: 5),
                                                width: 100,
                                                child: CachedNetworkImage(
                                                    imageUrl: widget.userInfo
                                                        .get('images')[index],
                                                    fit: BoxFit.cover,
                                                    cacheKey: 'gallery-${widget.uid}-$index'),
                                              )),
                                        );
                                      },
                                      itemCount: images.length,
                                    ),
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
                                      try {
                                        String chatID = '';
                                        Map<String, dynamic> chatRoomInfoMap = {
                                          "user1": FirebaseAuth
                                              .instance.currentUser!.uid
                                              .toString(),
                                          "user2": widget.uid,
                                          "user1Nickname": FirebaseAuth
                                              .instance.currentUser!.displayName ?? '',
                                          "user2Nickname": widget.name,
                                          "user1_image": FirebaseAuth
                                              .instance.currentUser!.photoURL ?? '',
                                          "user2_image": _profilePic,
                                          "lastMessage": "",
                                          "lastMessageSendBy": "",
                                          "unreadMessage": 0,
                                          "chatId": getChatRoomIdByUsernames(
                                              FirebaseAuth.instance.currentUser!
                                                  .displayName
                                                  .toString(),
                                              widget.name)
                                        };

                                        await FirebaseFirestore.instance
                                            .collection("chats")
                                            .where("user1",
                                                isEqualTo: FirebaseAuth
                                                    .instance.currentUser!.uid)
                                            .where("user2", isEqualTo: widget.uid)
                                            .get()
                                            .then((QuerySnapshot snapshot) {
                                          if (snapshot.docs.isNotEmpty) {
                                            HaveOrNot = true;
                                            chatID = snapshot.docs[0].id;
                                          }
                                        });
                                        
                                        await FirebaseFirestore.instance
                                            .collection("chats")
                                            .where("user2",
                                                isEqualTo: FirebaseAuth
                                                    .instance.currentUser!.uid)
                                            .where("user1", isEqualTo: widget.uid)
                                            .get()
                                            .then((QuerySnapshot snapshot) {
                                          if (snapshot.docs.isNotEmpty) {
                                            HaveOrNot = true;
                                            chatID = snapshot.docs[0].id;
                                          }
                                        });
                                        
                                        await FirebaseFirestore.instance
                                            .collection("chats")
                                            .where("chatId",
                                                isEqualTo:
                                                    getChatRoomIdByUsernames(
                                                        FirebaseAuth.instance
                                                            .currentUser!
                                                            .displayName
                                                            .toString(),
                                                        widget.name))
                                            .get()
                                            .then((QuerySnapshot snapshot) {
                                          if (snapshot.docs.isNotEmpty) {
                                            HaveOrNot = true;
                                          }
                                          if (HaveOrNot == false) {
                                            DatabaseService().createChatRoom(
                                                getChatRoomIdByUsernames(
                                                    FirebaseAuth.instance
                                                        .currentUser!.displayName
                                                        .toString(),
                                                    widget.name),
                                                chatRoomInfoMap);
                                            DatabaseService().addChat(
                                                FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                getChatRoomIdByUsernames(
                                                    FirebaseAuth.instance
                                                        .currentUser!.displayName
                                                        .toString(),
                                                    widget.name));
                                            DatabaseService().addChatSecondUser(
                                                widget.uid,
                                                getChatRoomIdByUsernames(
                                                    FirebaseAuth.instance
                                                        .currentUser!.displayName
                                                        .toString(),
                                                    widget.name));
                                            nextScreen(context, const HomePage());
                                          } else {
                                            nextScreenReplace(
                                                context,
                                                ChatScreen(
                                                  chatId: chatID,
                                                  chatWithUsername: widget.name,
                                                  id: FirebaseAuth
                                                      .instance.currentUser!.uid,
                                                  photoUrl: _profilePic,
                                                ));
                                          }
                                        });
                                        setState(() {
                                          selectedIndex = 1;
                                        });
                                      } catch (e, st) {
                                        FirebaseCrashlytics.instance.recordError(e, st, reason: 'createChatRoom');
                                        showSnackbar(context, Colors.red, 'Ошибка создания чата: $e');
                                      }
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Возраст: ",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 23,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      (widget.userInfo.get('age') ?? 0).toString(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 21),
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
                                      "Рост: ",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 23,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      widget.userInfo.get('rost') ?? 'не указан',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 21),
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
                                      "Хобби: ",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 23,
                                          fontWeight: FontWeight.bold),
                                      softWrap: true,
                                      textAlign: TextAlign.left,
                                    ),
                                    Flexible(
                                      child: Text(
                                        widget.userInfo.get('hobbi') != null && widget.userInfo.get('hobbi').toString().isNotEmpty
                                            ? widget.userInfo.get('hobbi').toString()
                                            : "не заполнено",
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 21),
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
                                      "Дети: ",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 23,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      (widget.userInfo.get('deti') ?? false)
                                          ? "есть"
                                          : "нет",
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 21),
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
                                      "Группа: ",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 23,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Flexible(
                                      child: Text(
                                        widget.userInfo.get('группа'),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 21),
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
                                      "Города: ",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 23,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      widget.userInfo.get('city'),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 21),
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
                                    const Text("О себе",
                                        style: TextStyle(
                                            fontSize: 23,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                        textAlign: TextAlign.left),
                                    const Padding(
                                        padding: EdgeInsets.only(bottom: 20.0)),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          child: Text(
                                            widget.userInfo.get('about'),
                                            style: const TextStyle(
                                                fontSize: 21,
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
}
