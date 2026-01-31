// ignore_for_file: library_private_types_in_public_api, unnecessary_string_escapes, non_constant_identifier_names, use_build_context_synchronously, deprecated_member_use

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:wbrs/app/helper/global.dart';
import 'package:wbrs/presentation/screens/list_of_users/show/somebody_profile.dart';
import 'package:wbrs/presentation/screens/shop/shop.dart';
import 'package:wbrs/service/database_service.dart';
import 'package:wbrs/app/helper/helper_function.dart';
import 'package:wbrs/service/notifications.dart';
import 'package:wbrs/app/widgets/message_tile.dart';
import 'package:wbrs/app/widgets/widgets.dart';
import 'package:random_string/random_string.dart';

class ChatScreen extends StatefulWidget {
  final String chatWithUsername, photoUrl, id, chatId;
  const ChatScreen({
    super.key,
    required this.chatWithUsername,
    required this.photoUrl,
    required this.id,
    required this.chatId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String messageId = '';
  Stream? messageStream;
  late String myName, myProfilePic, myUserName, myEmail;
  String? _image;
  TextEditingController messageTextEdittingController = TextEditingController();
  String group = '';
  bool online = false;
  bool isNotificationEnable = true;
  List userWOutN = [];
  Map chatInfo = {}, anotherUserInfo = {};
  bool _isUserDeleted = false;
  bool _isLoading = true;

  Future<void> getMyInfoFromSharedPreference() async {
    myName = HelperFunctions().getDisplayName().toString();
    myProfilePic = HelperFunctions().getUserProfileUrl().toString();
    myUserName = HelperFunctions().getUserName().toString();
    myEmail = HelperFunctions().getUserEmail().toString();

    DocumentSnapshot userDoc = await firebaseFirestore
        .collection('users')
        .doc(widget.id)
        .get();

    if (userDoc.exists) {
      group = userDoc.get('группа');
      online = userDoc.get('online');
    }

    setState(() {});
  }

  String getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return '$b\_$a';
    } else {
      return '$a\_$b';
    }
  }

  Future<void> addMessage(bool sendClicked, String type) async {
    if (messageTextEdittingController.text != '') {
      DocumentSnapshot querySnap = await firebaseFirestore
          .collection('users')
          .doc(widget.id)
          .get();
      String chatWith = querySnap.get('chatWithId');
      bool isUserInChat = chatWith == firebaseAuth.currentUser!.uid;

      isUserInChat
          ? null
          : DatabaseService().updateUnreadMessageCount(widget.chatId);
      String message = messageTextEdittingController.text;

      var lastMessageTs = DateTime.now();

      Map<String, dynamic> messageInfoMap = {
        'type': type,
        'message': type == 'text' ? message : _image,
        'sendBy': firebaseAuth.currentUser!.displayName,
        'sendByID': firebaseAuth.currentUser!.uid,
        'ts': lastMessageTs,
        'isRead': isUserInChat ? true : false,
      };

      //messageId
      if (messageId == '') {
        messageId = randomAlphaNumeric(12);
      }
      DatabaseService()
          .addMessage(widget.chatId, messageId, messageInfoMap)
          .then((value) {
            Map<String, dynamic> lastMessageInfoMap = {
              'lastMessage': message,
              'lastMessageSendTs': lastMessageTs,
              'lastMessageSendBy': firebaseAuth.currentUser!.displayName,
              'lastMessageSendByID': firebaseAuth.currentUser!.uid,
            };

            DatabaseService().updateLastMessageSend(
              widget.chatId,
              lastMessageInfoMap,
            );

            if (sendClicked) {
              // remove the text in the message input field
              messageTextEdittingController.text = '';
              // make message id blank to get regenerated on next message send
              messageId = '';
            }
          });

      if (!userWOutN.contains(widget.id) &&
          widget.id != firebaseAuth.currentUser!.uid) {
        DocumentSnapshot doc = await firebaseFirestore
            .collection('TOKENS')
            .doc(widget.id)
            .get();
        String token = doc.get('token');

        Map notificationBody = {
          'isChat': true,
          'chatId': widget.chatId,
          'chatWith': widget.chatWithUsername,
          'id': widget.id,
          'photoUrl': widget.photoUrl,
          'message': message,
        };

        NotificationsService().sendPushMessage(
          token,
          notificationBody,
          firebaseAuth.currentUser!.displayName.toString(),
          1,
          widget.chatId,
        );
      }
    }
    messageTextEdittingController.text = '';
  }

  Widget chatMessages() {
    if (_isUserDeleted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 100, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            const Text(
              'Пользователь удален',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Чат с этим пользователем больше недоступен',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Вернуться назад',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder(
      stream: messageStream,
      builder: (context, snapshot) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return snapshot.hasData
            ? snapshot.data.docs.length != 0
                  ? Column(
                      children: [
                        const Text(
                          'Самый простой способ начать общения - это',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                        TextButton(
                          onPressed: () {
                            nextScreenReplace(context, const ShopPage());
                          },
                          child: const Text(
                            'Подарок',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.72,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 0, top: 16),
                            itemCount: snapshot.data.docs.length,
                            reverse: true,
                            itemBuilder: (context, index) {
                              DocumentSnapshot ds = snapshot.data.docs[index];
                              ds.id;
                              if (ds['sendByID'] !=
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
                                  avatar: anotherUserInfo.isNotEmpty
                                      ? userImageWithCircle(
                                          anotherUserInfo['profilePic'],
                                          anotherUserInfo['группа'],
                                          anotherUserInfo['online'],
                                          50.0,
                                          50.0,
                                        )
                                      : Container(),
                                  chatId: widget.chatId,
                                  sender: ds['sendBy'],
                                  name: ds['sendBy'],
                                  message: ds,
                                  sentByMe:
                                      firebaseAuth.currentUser!.uid ==
                                      ds['sendByID'],
                                  isRead: ds['isRead'],
                                  isChat: true,
                                );
                              } else {
                                var x = ds.data().toString().contains(
                                  'deleteFor',
                                );
                                if (x) {
                                  if (ds['deleteFor'] !=
                                      firebaseAuth.currentUser!.uid) {
                                    return MessageTile(
                                      avatar: anotherUserInfo.isNotEmpty
                                          ? userImageWithCircle(
                                              anotherUserInfo['profilePic'],
                                              anotherUserInfo['группа'],
                                              anotherUserInfo['online'],
                                              50.0,
                                              50.0,
                                            )
                                          : Container(),
                                      chatId: widget.chatId,
                                      sender: ds['sendBy'],
                                      name: ds['sendBy'],
                                      message: ds,
                                      sentByMe:
                                          FirebaseAuth
                                              .instance
                                              .currentUser!
                                              .uid ==
                                          ds['sendByID'],
                                      isRead: ds['isRead'],
                                      isChat: true,
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                } else {
                                  return MessageTile(
                                    avatar: anotherUserInfo.isNotEmpty
                                        ? userImageWithCircle(
                                            anotherUserInfo['profilePic'],
                                            anotherUserInfo['группа'],
                                            anotherUserInfo['online'],
                                            50.0,
                                            50.0,
                                          )
                                        : Container(),
                                    chatId: widget.chatId,
                                    sender: ds['sendBy'],
                                    name: ds['sendBy'],
                                    message: ds,
                                    sentByMe:
                                        FirebaseAuth
                                            .instance
                                            .currentUser!
                                            .uid ==
                                        ds['sendByID'],
                                    isRead: ds['isRead'],
                                    isChat: true,
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Самый простой способ начать общение - это',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () {
                              nextScreenReplace(context, const ShopPage());
                            },
                            child: const Text(
                              'Подарок',
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    )
            : const Center(child: CircularProgressIndicator());
      },
    );
  }

  void getAndSetMessages() async {
    if (!_isUserDeleted) {
      messageStream = await DatabaseService().getChatRoomMessages(
        widget.chatId,
      );
      setState(() {});
    }
  }

  void doThisOnLaunch() async {
    try {
      DocumentSnapshot userDoc = await firebaseFirestore
          .collection('users')
          .doc(widget.id)
          .get();

      if (!userDoc.exists) {
        // Пользователь удален
        setState(() {
          _isUserDeleted = true;
          _isLoading = false;
        });
        return;
      }

      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      if (userData == null) {
        // Данные пользователя null
        setState(() {
          _isUserDeleted = true;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        anotherUserInfo = userData;
        _isUserDeleted = false;
      });

      await getMyInfoFromSharedPreference();
      getAndSetMessages();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Ошибка при загрузке данных пользователя: $e');
      setState(() {
        _isUserDeleted = true;
        _isLoading = false;
      });
    }
  }

  void chatWith_Update(String id) async {
    if (_isUserDeleted) return;

    String myId = firebaseAuth.currentUser!.uid;
    await firebaseFirestore.collection('users').doc(myId).update({
      'chatWithId': id,
    });
    DocumentSnapshot chat = await firebaseFirestore
        .collection('chats')
        .doc(widget.chatId)
        .get();

    if (chat.exists) {
      setState(() {
        chatInfo = chat.data() as Map;
        userWOutN = chatInfo['usersWOutNotifications'] ?? [];
        isNotificationEnable = !userWOutN.contains(
          firebaseAuth.currentUser!.uid,
        );
      });

      var chatSnapshot = firebaseFirestore
          .collection('chats')
          .doc(widget.chatId);

      String lastMessageSendBy = chat.get('lastMessageSendBy');

      if (lastMessageSendBy != firebaseAuth.currentUser!.displayName) {
        chatSnapshot.update({'unreadMessage': 0});
      }
    }
  }

  Future<bool> outOfChat() async {
    String myId = firebaseAuth.currentUser!.uid;
    await firebaseFirestore.collection('users').doc(myId).update({
      'chatWithId': '',
    });

    return true;
  }

  @override
  void initState() {
    super.initState();
    doThisOnLaunch();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isUserDeleted) {
          chatWith_Update(widget.id);
        }
      });
    }
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

  void switchNotification() async {
    if (_isUserDeleted) return;

    String myUID = firebaseAuth.currentUser!.uid;
    setState(() {
      if (!isNotificationEnable) {
        userWOutN.remove(myUID);
      } else {
        userWOutN.add(myUID);
      }
    });
    firebaseFirestore.collection('chats').doc(widget.chatId).update({
      'usersWOutNotifications': userWOutN,
    });
    isNotificationEnable = !isNotificationEnable;
  }

  Widget _buildUserDeletedScreen() {
    return Stack(
      children: [
        Image.asset(
          'assets/fon2.jpg',
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Чат недоступен',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.person_off, size: 80, color: grey),
                        const SizedBox(height: 20),
                        Text(
                          'Пользователь удален',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Аккаунт пользователя был удален. Чат больше недоступен.',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Вернуться назад',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isUserDeleted) {
      return _buildUserDeletedScreen();
    }

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Image.asset(
              'assets/fon2.jpg',
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Image.asset(
          'assets/fon2.jpg',
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
                      : const Icon(Icons.notifications_off_outlined),
                ),
                FloatingActionButton(
                  backgroundColor: Colors.transparent,
                  onPressed: () async {
                    if (!mounted) return;
                    nextScreen(
                      context,
                      SomebodyProfile(
                        uid: widget.id,
                        photoUrl: widget.photoUrl,
                        name: widget.chatWithUsername,
                        userInfo: anotherUserInfo,
                      ),
                    );
                  },
                  child: userImageWithCircle(
                    widget.photoUrl,
                    group,
                    online,
                    50.0,
                    50.0,
                  ),
                ),
              ],
              titleTextStyle: TextStyle(
                overflow: TextOverflow.ellipsis,
                color: Colors.white,
              ),
              titleSpacing: 0,
              title: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          widget.chatWithUsername,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        statusRow(
                          anotherUserInfo.toString().contains('online')
                              ? anotherUserInfo['online']
                              : false,
                          anotherUserInfo.toString().contains('lastOnlineTS')
                              ? anotherUserInfo['lastOnlineTS'].toDate()
                              : DateTime.now().subtract(
                                  const Duration(minutes: 5),
                                ),
                          anotherUserInfo['pol'] ?? '',
                        ),
                      ],
                    ),
                  ],
                ),
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
                    child: chatMessages(),
                  ),
                  if (!_isUserDeleted)
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
                              color: darkGrey,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: MediaQuery.of(context).size.width,
                                  maxWidth: MediaQuery.of(context).size.width,
                                ),
                                child: Row(
                                  children: [
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: 50,
                                        minWidth:
                                            MediaQuery.of(context).size.width -
                                            70,
                                        maxWidth:
                                            MediaQuery.of(context).size.width -
                                            60,
                                      ),
                                      child: TextField(
                                        controller:
                                            messageTextEdittingController,
                                        keyboardType: TextInputType.multiline,
                                        minLines: 1,
                                        maxLines: 5,
                                        onChanged: (value) {},
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Введите сообщение',
                                          hintStyle: TextStyle(color: white70),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        if (messageTextEdittingController.text
                                            .trim()
                                            .isEmpty)
                                          return;
                                        try {
                                          await addMessage(true, 'text');
                                        } catch (e) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Не удалось отправить сообщение',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Icon(
                                        Icons.send,
                                        color:
                                            messageTextEdittingController
                                                    .text !=
                                                ''
                                            ? Colors.white
                                            : white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<String> uploadFile(String filePath) async {
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
