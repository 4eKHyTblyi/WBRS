// ignore_for_file: library_private_types_in_public_api, unnecessary_string_escapes, non_constant_identifier_names, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:wbrs/helper/global.dart';
import 'package:wbrs/pages/auth/somebody_profile.dart';
import 'package:wbrs/pages/shop.dart';
import 'package:wbrs/service/database_service.dart';
import 'package:wbrs/helper/helper_function.dart';
import 'package:wbrs/service/notifications.dart';
import 'package:wbrs/widgets/message_tile.dart';
import 'package:wbrs/widgets/widgets.dart';
import 'package:random_string/random_string.dart';

class ChatScreen extends StatefulWidget {
  final String chatWithUsername, photoUrl, id, chatId;
  const ChatScreen(
      {super.key,
      required this.chatWithUsername,
      required this.photoUrl,
      required this.id,
      required this.chatId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String messageId = "";
  Stream? messageStream;
  late String myName, myProfilePic, myUserName, myEmail;
  String? _image;
  TextEditingController messageTextEdittingController = TextEditingController();
  String group = '';
  bool isNotificationEnable = true;
  List userWOutN = [];
  Map chatInfo = {};

  getMyInfoFromSharedPreference() async {
    myName = HelperFunctions().getDisplayName().toString();
    myProfilePic = HelperFunctions().getUserProfileUrl().toString();
    myUserName = HelperFunctions().getUserName().toString();
    myEmail = HelperFunctions().getUserEmail().toString();

    group = await firebaseFirestore
        .collection('users')
        .doc(widget.id)
        .get()
        .then((value) {
      return value.get('группа');
    });
  }

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  addMessage(bool sendClicked, String type) async {
    if (messageTextEdittingController.text != "") {
      QuerySnapshot querySnap = await firebaseFirestore
          .collection('users')
          .where('fullName', isEqualTo: widget.chatWithUsername)
          .get();
      String chatWith = querySnap.docs[0]['chatWithId'];
      bool isUserInChat = chatWith == firebaseAuth.currentUser!.uid;

      isUserInChat
          ? null
          : DatabaseService().updateUnreadMessageCount(widget.chatId);
      String message = messageTextEdittingController.text;

      var lastMessageTs = DateTime.now();

      Map<String, dynamic> messageInfoMap = {
        "type": type,
        "message": type == "text" ? message : _image,
        "sendBy": firebaseAuth.currentUser!.displayName,
        "sendByID": firebaseAuth.currentUser!.uid,
        "ts": lastMessageTs,
        "isRead": isUserInChat ? true : false
      };

      //messageId
      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }
      DatabaseService()
          .addMessage(widget.chatId, messageId, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": lastMessageTs,
          "lastMessageSendBy": firebaseAuth.currentUser!.displayName,
          "lastMessageSendByID": firebaseAuth.currentUser!.uid,
        };

        DatabaseService()
            .updateLastMessageSend(widget.chatId, lastMessageInfoMap);

        if (sendClicked) {
          // remove the text in the message input field
          messageTextEdittingController.text = "";
          // make message id blank to get regenerated on next message send
          messageId = "";
        }
      });

      if (!userWOutN.contains(widget.id)) {
        DocumentSnapshot doc = await firebaseFirestore
            .collection('TOKENS')
            .doc(firebaseAuth.currentUser!.uid)
            .get();
        DocumentSnapshot snap =
            await firebaseFirestore.collection('users').doc(widget.id).get();
        String token = doc.get('token');
        snap.get('fullName');

        Map notificationBody = {
          'isChat': true,
          'chatId': widget.chatId,
          'chatWith': widget.chatWithUsername,
          'id': widget.id,
          'photoUrl': widget.photoUrl,
          'message': message,
        };

        NotificationsService().sendPushMessage(token, notificationBody,
            firebaseAuth.currentUser!.displayName.toString(), 4, widget.chatId);
      }
    }
    messageTextEdittingController.text = "";
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: messageStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? snapshot.data.docs.length != 0
                ? Column(
                    children: [
                      const Text(
                        'Самый простой способ начать общение - это',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                          onPressed: () {
                            nextScreen(context, const ShopPage());
                          },
                          child: const Text(
                            'Подарок',
                            style: TextStyle(color: Colors.green),
                          )),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.72,
                        child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 0, top: 16),
                            itemCount: snapshot.data.docs.length,
                            reverse: true,
                            itemBuilder: (context, index) {
                              DocumentSnapshot ds = snapshot.data.docs[index];
                              ds.id;
                              if (ds["sendByID"] !=
                                  firebaseAuth.currentUser!.uid) {
                                firebaseFirestore
                                    .collection('chats')
                                    .doc(widget.chatId)
                                    .collection('chats')
                                    .doc(ds.id)
                                    .update({'isRead': true});
                              }

                              Map newDs = ds.data() as Map;

                              if (newDs.containsKey('')) {
                                return MessageTile(
                                  chatId: widget.chatId,
                                  sender: ds["sendBy"],
                                  name: ds["sendBy"],
                                  message: ds,
                                  sentByMe: firebaseAuth.currentUser!.uid ==
                                      ds["sendByID"],
                                  isRead: ds["isRead"],
                                  isChat: true,
                                );
                              } else {
                                var x =
                                    ds.data().toString().contains('deleteFor');
                                if (x) {
                                  if (ds["deleteFor"] !=
                                      firebaseAuth.currentUser!.uid) {
                                    return MessageTile(
                                      chatId: widget.chatId,
                                      sender: ds["sendBy"],
                                      name: ds["sendBy"],
                                      message: ds,
                                      sentByMe: FirebaseAuth
                                              .instance.currentUser!.uid ==
                                          ds["sendByID"],
                                      isRead: ds["isRead"],
                                      isChat: true,
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                } else {
                                  return MessageTile(
                                    chatId: widget.chatId,
                                    sender: ds["sendBy"],
                                    name: ds["sendBy"],
                                    message: ds,
                                    sentByMe: FirebaseAuth
                                            .instance.currentUser!.uid ==
                                        ds["sendByID"],
                                    isRead: ds["isRead"],
                                    isChat: true,
                                  );
                                }
                              }
                            }),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      children: [
                        const Text(
                          'Самый простой способ начать общение - это',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                        TextButton(
                            onPressed: () {
                              nextScreen(context, const ShopPage());
                            },
                            child: const Text(
                              'Подарок',
                              style: TextStyle(color: Colors.green),
                            ))
                      ],
                    ),
                  )
            : const Center(child: CircularProgressIndicator());
      },
    );
  }

  getAndSetMessages() async {
    messageStream = await DatabaseService().getChatRoomMessages(widget.chatId);
    setState(() {});
  }

  doThisOnLaunch() async {
    await getMyInfoFromSharedPreference();
    getAndSetMessages();
  }

  chatWith_Update(String id) async {
    String myId = firebaseAuth.currentUser!.uid;
    await firebaseFirestore
        .collection('users')
        .doc(myId)
        .update({'chatWithId': id});
    DocumentSnapshot chat =
        await firebaseFirestore.collection('chats').doc(widget.chatId).get();

    setState(() {
      chatInfo = chat.data() as Map;
      userWOutN = chatInfo['usersWOutNotifications'] ?? [];
      isNotificationEnable = !userWOutN.contains(firebaseAuth.currentUser!.uid);
    });

    var chatSnapshot = firebaseFirestore.collection('chats').doc(widget.chatId);

    String lastMessageSendBy = chat.get('lastMessageSendBy');

    if (lastMessageSendBy != firebaseAuth.currentUser!.displayName) {
      chatSnapshot.update({
        'unreadMessage': 0,
      });
    }
  }

  Future<bool> outOfChat() async {
    String myId = firebaseAuth.currentUser!.uid;
    await firebaseFirestore
        .collection('users')
        .doc(myId)
        .update({'chatWithId': ''});

    return true;
  }

  @override
  void initState() {
    doThisOnLaunch();
    chatWith_Update(widget.id);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    outOfChat();
  }

  @override
  void deactivate() {
    super.deactivate();
    outOfChat();
  }

  final ScrollController _scrollController = ScrollController();

  switchNotification() async {
    String myUID = firebaseAuth.currentUser!.uid;
    setState(() {
      if (!isNotificationEnable) {
        userWOutN.remove(myUID);
      } else {
        userWOutN.add(myUID);
      }
    });
    firebaseFirestore
        .collection('chats')
        .doc(widget.chatId)
        .update({'usersWOutNotifications': userWOutN});
    isNotificationEnable = !isNotificationEnable;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          "assets/fon2.jpg",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        PopScope(
          onPopInvoked: (bool value) {
            outOfChat();
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                    onPressed: () {
                      switchNotification();
                    },
                    icon: isNotificationEnable
                        ? const Icon(Icons.notifications_on_outlined)
                        : const Icon(Icons.notifications_off_outlined))
              ],
              title: Row(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: FloatingActionButton(
                        backgroundColor: Colors.transparent,
                        onPressed: () async {
                          DocumentSnapshot doc = await FirebaseFirestore
                              .instance
                              .collection('users')
                              .doc(widget.id)
                              .get();
                          Images = doc.get('images');
                          CountImages = Images.length;
                          if (!mounted) return;
                          nextScreen(
                              context,
                              SomebodyProfile(
                                uid: widget.id,
                                photoUrl: widget.photoUrl,
                                name: widget.chatWithUsername,
                                userInfo: await firebaseFirestore
                                    .collection('users')
                                    .doc(widget.id)
                                    .get(),
                              ));
                        },
                        child: userImageWithCircle(
                            widget.photoUrl, group, 50.0, 50.0),
                      )),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(widget.chatWithUsername,
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
              backgroundColor: Colors.transparent,
            ),
            body: SingleChildScrollView(
              controller: _scrollController,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: chatMessages()),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.bottomCenter,
                          constraints: BoxConstraints(
                            minHeight:
                                MediaQuery.of(context).size.height * 0.07,
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.35,
                          ),
                          width: MediaQuery.of(context).size.width,
                          child: Container(
                            color: Colors.black.withOpacity(0.8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  minWidth: MediaQuery.of(context).size.width,
                                  maxWidth: MediaQuery.of(context).size.width),
                              child: Row(
                                children: [
                                  ConstrainedBox(
                                      constraints: BoxConstraints(
                                          minHeight: 50,
                                          minWidth: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              70,
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              60),
                                      child: TextField(
                                        controller:
                                            messageTextEdittingController,
                                        keyboardType: TextInputType.multiline,
                                        minLines: 1,
                                        maxLines: 5,
                                        onChanged: (value) {},
                                        style: const TextStyle(
                                            color: Colors.white),
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Введите сообщение",
                                            hintStyle: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.6))),
                                      )),
                                  GestureDetector(
                                    onTap: () {
                                      addMessage(true, 'text');
                                    },
                                    child: Icon(
                                      Icons.send,
                                      color:
                                          messageTextEdittingController.text !=
                                                  ""
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  uploadFile(String filePath) async {
    File file = File(filePath);
    var storage = FirebaseStorage.instance;
    String ref = '${widget.id}/${DateTime.now().toString()}.jpg';
    try {
      await storage.ref(ref).putFile(file);
    } on FirebaseException catch (_) {}

    String downloadUrl = await storage.ref(ref).getDownloadURL();
    return downloadUrl;
  }
}
