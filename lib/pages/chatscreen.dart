// ignore_for_file: library_private_types_in_public_api, unnecessary_string_escapes, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messenger/helper/global.dart';
import 'package:messenger/pages/auth/somebody_profile.dart';
import 'package:messenger/pages/shop.dart';
import 'package:messenger/service/database_service.dart';
import 'package:messenger/helper/helper_function.dart';
import 'package:messenger/service/notifications.dart';
import 'package:messenger/widgets/message_tile.dart';
import 'package:messenger/widgets/widgets.dart';
import 'package:random_string/random_string.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class ChatScreen extends StatefulWidget {
  final String chatWithUsername, photoUrl, id, chatId;
  const ChatScreen(
      {Key? key,
      required this.chatWithUsername,
      required this.photoUrl,
      required this.id,
      required this.chatId})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String messageId = "";
  Stream? messageStream;
  late String myName, myProfilePic, myUserName, myEmail;
  TextEditingController messageTextEdittingController = TextEditingController();
  bool _isSending = false;

  getMyInfoFromSharedPreference() async {
    myName = HelperFunctions().getDisplayName().toString();
    myProfilePic = HelperFunctions().getUserProfileUrl().toString();
    myUserName = HelperFunctions().getUserName().toString();
    myEmail = HelperFunctions().getUserEmail().toString();
  }

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  addMessage(bool sendClicked) async {
    if (messageTextEdittingController.text.trim().isEmpty || _isSending) {
      return;
    }
    setState(() {
      _isSending = true;
    });
    try {
      final QuerySnapshot querySnap = await FirebaseFirestore.instance
          .collection('users')
          .where('fullName', isEqualTo: widget.chatWithUsername)
          .limit(1)
          .get();
      if (querySnap.docs.isEmpty) {
        showSnackbar(context, Colors.red, 'Пользователь не найден');
        setState(() {
          _isSending = false;
        });
        return;
      }
      
      final String chatWith = (querySnap.docs.first.data() as Map<String, dynamic>)['chatWithId'] ?? '';
      final bool isUserInChat = chatWith == FirebaseAuth.instance.currentUser!.uid;

      if (!isUserInChat) {
        try {
          await DatabaseService().updateUnreadMessageCount(widget.chatId);
        } catch (e, st) {
          FirebaseCrashlytics.instance.recordError(e, st, reason: 'updateUnreadMessageCount');
        }
      }
      
      final String message = messageTextEdittingController.text.trim();
      final DateTime lastMessageTs = DateTime.now();

      final Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": FirebaseAuth.instance.currentUser!.displayName ?? '',
        "sendByID": FirebaseAuth.instance.currentUser!.uid,
        "ts": lastMessageTs,
        "imgUrl": FirebaseAuth.instance.currentUser!.photoURL ?? '',
        "isRead": isUserInChat ? true : false
      };

      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }

      final result = await DatabaseService().addMessage(widget.chatId, messageId, messageInfoMap);
      if (result != null) {
        throw Exception('Failed to add message: $result');
      }

      final Map<String, dynamic> lastMessageInfoMap = {
        "lastMessage": message,
        "lastMessageSendTs": lastMessageTs,
        "lastMessageSendBy": FirebaseAuth.instance.currentUser!.displayName ?? '',
        "lastMessageSendByID": FirebaseAuth.instance.currentUser!.uid,
      };
      
      try {
        await DatabaseService().updateLastMessageSend(widget.chatId, lastMessageInfoMap);
      } catch (e, st) {
        FirebaseCrashlytics.instance.recordError(e, st, reason: 'updateLastMessageSend');
      }

      if (sendClicked) {
        messageTextEdittingController.text = "";
        messageId = "";
      }

      try {
        final DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('TOKENS')
            .doc(widget.id)
            .get();
        final DocumentSnapshot snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.id)
            .get();
        
        if (doc.exists && snap.exists) {
          final String token = doc.get('token') ?? '';
          final String name = snap.get('fullName') ?? '';

          if (!isUserInChat && token.isNotEmpty) {
            NotificationsService().sendPushMessage(token, message, name, 4,
                FirebaseAuth.instance.currentUser!.photoURL ?? '', widget.chatId);
          }
        }
      } catch (e, st) {
        FirebaseCrashlytics.instance.recordError(e, st, reason: 'sendPushNotification');
      }
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'sendMessage');
      showSnackbar(context, Colors.red, 'Не удалось отправить сообщение: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Widget chatMessageTile(String message, bool sendByMe, bool isRead) {
    Size size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  bottomRight: sendByMe
                      ? const Radius.circular(0)
                      : const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: sendByMe
                      ? const Radius.circular(24)
                      : const Radius.circular(0),
                ),
                color: sendByMe ? Colors.orange : Colors.blue.shade400,
              ),
              padding: EdgeInsets.only(
                  top: 4,
                  bottom: 4,
                  left: sendByMe ? 0 : 24,
                  right: sendByMe ? 24 : 0),
              child: Container(
                constraints:
                    BoxConstraints(minWidth: 50, maxWidth: size.width / 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      message,
                      maxLines: 100,
                      softWrap: true,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ],
    );
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: messageStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Ошибка загрузки сообщений: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }
        
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
                        height: MediaQuery.of(context).size.height - 150,
                        child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 70, top: 16),
                            itemCount: snapshot.data.docs.length,
                            reverse: true,
                            itemBuilder: (context, index) {
                              DocumentSnapshot ds = snapshot.data.docs[index];
                              if (ds["sendByID"] !=
                                  FirebaseAuth.instance.currentUser!.uid) {
                                try {
                                  FirebaseFirestore.instance
                                      .collection('chats')
                                      .doc(widget.chatId)
                                      .collection('messages')
                                      .doc(ds.id)
                                      .update({'isRead': true});
                                } catch (e, st) {
                                  FirebaseCrashlytics.instance.recordError(e, st, reason: 'markMessageAsRead');
                                }
                              }

                              if (ds["message"] == null) {
                                return MessageTile(
                                    sender: ds["sendBy"] ?? '',
                                    name: ds["sendBy"] ?? '',
                                    message: ds["image"] ?? '',
                                    sentByMe: FirebaseAuth
                                            .instance.currentUser!.uid ==
                                        ds["sendByID"],
                                    isRead: ds["isRead"] ?? false);
                              } else {
                                return MessageTile(
                                    sender: ds["sendBy"] ?? '',
                                    name: ds["sendBy"] ?? '',
                                    message: ds["message"] ?? '',
                                    sentByMe: FirebaseAuth
                                            .instance.currentUser!.uid ==
                                        ds["sendByID"],
                                    isRead: ds["isRead"] ?? false);
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
    try {
      String myId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(myId)
          .update({'chatWithId': id});
      
      DocumentSnapshot chat = await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .get();

      if (chat.exists) {
        var chatSnapshot =
            FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

        String lastMessageSendBy = chat.get('lastMessageSendBy') ?? '';

        if (lastMessageSendBy != FirebaseAuth.instance.currentUser!.displayName) {
          await chatSnapshot.update({
            'unreadMessage': 0,
          });
        }
      }
    } catch (e, st) {
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'chatWith_Update');
    }
  }

  Future<bool> outOfChat() async {
    try {
      String myId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(myId)
          .update({'chatWithId': ''});

      return true;
    } catch (e, st) {
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'outOfChat');
      return false;
    }
  }

  @override
  void initState() {
    doThisOnLaunch();
    chatWith_Update(widget.id);
    super.initState();
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
        WillPopScope(
          onWillPop: () {
            return outOfChat();
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              title: Row(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: SizedBox(
                        height: 45,
                        width: 45,
                        child: FloatingActionButton(
                            onPressed: () async {
                              DocumentSnapshot doc = await FirebaseFirestore
                                  .instance
                                  .collection('users')
                                  .doc(widget.id)
                                  .get();
                              Images = doc.get('images');
                              CountImages = Images.length;
                              nextScreen(
                                  context,
                                  SomebodyProfile(
                                    uid: widget.id,
                                    photoUrl: doc.get('profilePic') ?? widget.photoUrl,
                                    name: widget.chatWithUsername,
                                    userInfo: await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(widget.id)
                                        .get(),
                                  ));
                            },
                            child: widget.photoUrl != ''
                                ? CachedNetworkImage(
                                    imageUrl: widget.photoUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 45,
                                    cacheKey: 'avatar-${widget.id}',
                                    placeholder: (context, url) => const SizedBox.shrink(),
                                    errorWidget: (context, url, error) => Image.asset('assets/profile.png'),
                                  )
                                : Image.asset('assets/profile.png')),
                      )),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(widget.chatWithUsername),
                ],
              ),
              backgroundColor: Colors.transparent,
            ),
            body: Stack(
              children: [
                chatMessages(),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Colors.black.withOpacity(0.8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                            child: TextField(
                          controller: messageTextEdittingController,
                          onChanged: (value) {},
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "type a message",
                              hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.6))),
                        )),
                        GestureDetector(
                          onTap: _isSending
                              ? null
                              : () {
                                  addMessage(true);
                                },
                          child: Icon(
                            Icons.send,
                            color: _isSending ? Colors.grey : Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
