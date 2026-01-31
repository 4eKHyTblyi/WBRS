import 'package:wbrs/app/helper/global.dart';
import 'package:wbrs/app/helper/helper_function.dart';
import 'package:wbrs/presentation/screens/list_of_users/show/somebody_profile.dart';
import 'package:wbrs/presentation/screens/list_of_meets/meetings.dart';
import 'package:wbrs/service/database_service.dart';
import 'package:wbrs/service/notifications.dart';
import 'package:wbrs/app/widgets/message_tile.dart';
import 'package:wbrs/app/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../edit_meet/edit_meet.dart';

class UserInfo {
  String name;
  String age;
  String city;
  String imageUrl;
  String group;
  String uid;
  Map userInfo;

  UserInfo(
    this.name,
    this.age,
    this.city,
    this.imageUrl,
    this.group,
    this.uid,
    this.userInfo,
  );
}

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final List users;
  final bool isUserJoin;
  const ChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.users,
    required this.isUserJoin,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  Stream? usersInMeet;
  List userWOutN = [];

  TextEditingController messageController = TextEditingController();
  bool isMeAdmin = false;

  List<UserInfo> userInfo = [];
  bool isUserJoin = false;
  bool isMeKicked = false;
  late DocumentSnapshot meet;
  bool isNotificationOff = false;
  Map meetInfo = {};
  bool awaitUsers = false;
  String meetDescription = '';

  void isMeAdminCheck() async {
    String myId = firebaseAuth.currentUser!.uid;
    meetInfo = meet.data() as Map;
    meetDescription = meetInfo['description']?.toString() ?? '';
    isMeAdmin = meetInfo['admin'] == myId;
    if (meetInfo.containsKey('kicked')) {
      isMeKicked = meetInfo['kicked'].contains(myId);
    }
  }

  void getMeet() async {
    meet = await firebaseFirestore
        .collection('meets')
        .doc(widget.groupId)
        .get();
    isMeAdminCheck();
  }

  void checkNotification() {
    isNotificationOff = userWOutN.contains(firebaseAuth.currentUser!.uid);
  }

  @override
  void initState() {
    super.initState();
    getMeet();
    getUsers();
    isUserJoin = widget.isUserJoin;
    getAndSetMessages();
    getToken();
  }

  @override
  void dispose() {
    messageController.dispose();
    userInfo.clear();
    userWOutN.clear();
    super.dispose();
  }

  void getToken() async {
    firebaseMessaging.getNotificationSettings();
  }

  @override
  Widget build(BuildContext context) {
    Widget listUsers() {
      List users = userInfo;

      return StreamBuilder(
        stream: usersInMeet,
        builder: (context, snapshot) {
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return ListTile(
                textColor: Colors.white,
                onTap: () async {
                  UserInfo user = userInfo[index];
                  nextScreen(
                    context,
                    SomebodyProfile(
                      uid: user.uid,
                      photoUrl: user.imageUrl,
                      name: user.name,
                      userInfo: user.userInfo,
                    ),
                  );
                },
                trailing:
                    isMeAdmin &&
                        users[index].uid != firebaseAuth.currentUser!.uid
                    ? IconButton(
                        onPressed: () async {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: darkGrey,
                                elevation: 0.0,
                                titleTextStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                                contentTextStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                                content: const Text(
                                  'Вы уверены, что хотите исключить этого пользователя?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Нет',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Map doc = await firebaseFirestore
                                          .collection('meets')
                                          .doc(widget.groupId)
                                          .get()
                                          .then((doc) => doc.data() as Map);
                                      List kicked = doc['kicked'] ?? [];
                                      String uid = users[index].uid;
                                      kicked.add(uid);
                                      userInfo.removeWhere(
                                        (element) => element.uid == uid,
                                      );
                                      users.removeWhere(
                                        (element) => element.uid == uid,
                                      );
                                      List newUsers = doc['users'];
                                      newUsers.removeWhere(
                                        (element) => element == uid,
                                      );
                                      firebaseFirestore
                                          .collection('meets')
                                          .doc(widget.groupId)
                                          .update({
                                            'users': newUsers,
                                            'kicked': kicked,
                                          });

                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                      setState(() {});
                                    },
                                    child: const Text(
                                      'Да',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                      )
                    : null,
                title: Text(userInfo[index].name),
                subtitle: Row(
                  children: [
                    int.parse(userInfo[index].age) % 10 == 0
                        ? Text('${userInfo[index].age} лет')
                        : int.parse(userInfo[index].age) % 10 == 1
                        ? Text('${userInfo[index].age} год')
                        : int.parse(userInfo[index].age) % 10 != 5
                        ? Text('${userInfo[index].age} года')
                        : Text('${userInfo[index].age} лет'),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 120,
                      child: Text(
                        'Город ${userInfo[index].city}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                leading: SizedBox(
                  width: 50,
                  height: 50,
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(200),
                      child: userImageWithCircle(
                        userInfo[index].imageUrl,
                        userInfo[index].group,
                        userInfo[index].userInfo['online'],
                        60.0,
                        60.0,
                      ),
                    ),
                  ),
                ),
                dense: false,
              );
            },
          );
        },
      );
    }

    Widget buildMeetDescription() {
      return Container(
        height: 100,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: grey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orangeAccent, size: 20),
                SizedBox(width: 8),
                Text(
                  'Описание встречи',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Container(
              constraints: BoxConstraints(maxHeight: 60),
              child: Text(
                meetDescription.isNotEmpty
                    ? meetDescription
                    : 'Описание отсутствует',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: white70, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    showUsers() {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (ctx, StateSetter setState) {
              return Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(boxShadow: []),
                    child: Image.asset(
                      'assets/fon.jpg',
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                      scale: 0.6,
                    ),
                  ),
                  Scaffold(
                    backgroundColor: Colors.transparent,
                    appBar: AppBar(
                      backgroundColor: Colors.orangeAccent,
                      title: const Text('Список пользователей'),
                    ),
                    body: Column(
                      children: [
                        buildMeetDescription(),
                        Container(
                          height: 300,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          child: listUsers(),
                        ),
                        if (isUserJoin)
                          ElevatedButton(
                            onPressed: () {
                              getOutFromChat();
                            },
                            child: const Text(
                              'Выйти из встречи',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(boxShadow: []),
          child: Image.asset(
            'assets/fon.jpg',
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            scale: 0.6,
          ),
        ),
        awaitUsers
            ? const Center(child: CircularProgressIndicator())
            : Scaffold(
                appBar: AppBar(
                  toolbarTextStyle: const TextStyle(color: Colors.black),
                  title: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.groupName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 18),
                        ),
                        if (meetDescription.isNotEmpty)
                          SizedBox(
                            height: 16,
                            child: Text(
                              meetDescription,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    isUserJoin
                        ? IconButton(
                            onPressed: () {
                              List users = widget.users;
                              users.remove(firebaseAuth.currentUser!.uid);
                              firebaseFirestore
                                  .collection('meets')
                                  .doc(widget.groupId)
                                  .update({'users': users});
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.output_sharp),
                          )
                        : const SizedBox(),
                    GestureDetector(
                      onTap: () {
                        switchNotification();
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.notifications),
                          Text(
                            !isNotificationOff ? 'Вкл' : 'Выкл',
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    isMeAdmin
                        ? IconButton(
                            onPressed: () {
                              nextScreenReplace(context, EditMeet(meet: meet));
                            },
                            icon: const Icon(Icons.edit_calendar_outlined),
                          )
                        : const SizedBox(),
                    IconButton(
                      onPressed: () async {
                        if (userInfo.isEmpty) {
                          for (int i = 0; i < widget.users.length; i++) {
                            DocumentSnapshot doc = await firebaseFirestore
                                .collection('users')
                                .doc(widget.users[i])
                                .get();
                            if (doc.exists) {
                              try {
                                UserInfo someUserInfo = UserInfo(
                                  doc.get('fullName'),
                                  doc.get('age').toString(),
                                  doc.get('city'),
                                  doc.get('profilePic'),
                                  doc.get('группа'),
                                  doc.get('uid'),
                                  doc.data() as Map,
                                );
                                userInfo.add(someUserInfo);
                              } on Exception catch (e) {
                                if (context.mounted) {
                                  showSnackbar(context, Colors.red, e);
                                }
                              }
                            }
                          }
                        }
                        if (context.mounted) {
                          if (!awaitUsers) {
                            showUsers();
                          }
                        }
                      },
                      icon: const Icon(Icons.people),
                    ),
                  ],
                  backgroundColor: Colors.orangeAccent.shade400,
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Image.asset(
                            'assets/fon.jpg',
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.cover,
                            scale: 0.6,
                          ),
                          if (meetDescription.isNotEmpty && !isMeKicked)
                            buildMeetDescription(),
                          chatMessages(),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.grey[700],
                      child: isUserJoin
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: messageController,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'Отправить сообщение...',
                                        hintStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      if (messageController.text.isNotEmpty) {
                                        await getUsers();
                                        sendMessage();
                                      }
                                    },
                                    child: const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : isMeKicked
                          ? messagePanel('Вы были исключены из встречи')
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: messageController,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText:
                                            'Вы не являетесь участником встречи',
                                        hintStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      joinUser(
                                        firebaseAuth.currentUser!.uid,
                                        widget.groupId,
                                      );
                                      setState(() {
                                        isUserJoin = true;
                                      });
                                      messageController.text =
                                          '${firebaseAuth.currentUser!.displayName} присоединился ко встрече';
                                      addNotification();
                                      getAndSetMessages();
                                      messageController.text = '';
                                    },
                                    child: const Text(
                                      'Присоедениться',
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  Widget messagePanel(String msg) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      width: MediaQuery.of(context).size.width,
      color: Colors.grey[700],
      child: Text(
        msg,
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  void switchNotification() async {
    String myUID = firebaseAuth.currentUser!.uid;
    setState(() {
      if (isNotificationOff) {
        userWOutN.remove(myUID);
      } else {
        userWOutN.add(myUID);
      }
      isNotificationOff = !isNotificationOff;
    });

    await firebaseFirestore.collection('meets').doc(widget.groupId).update({
      'usersWithoutNotification': userWOutN,
    });
    checkNotification();
    if (mounted) {
      showSnackbar(
        context,
        Colors.black54,
        "Уведомления ${isNotificationOff ? "выключены" : "включены"}",
      );
    }
  }

  void getOutFromChat() async {
    var chat = firebaseFirestore.collection('meets').doc(widget.groupId);

    String myId = firebaseAuth.currentUser!.uid;

    var chatDoc = await chat.get();
    List users = chatDoc.get('users');
    users.remove(myId);

    chat.update({'users': users});

    var messages = await chat.collection('messages').get();

    for (var element in messages.docs) {
      firebaseFirestore
          .collection('users')
          .doc(myId)
          .collection('removed_meets')
          .doc(widget.groupId)
          .collection('messages')
          .doc(element.id)
          .set(element.data());
    }

    if (mounted) {
      nextScreenReplace(context, const MeetingPage());
    }
  }

  void getAndSetMessages() async {
    if (isUserJoin) {
      chats = await DatabaseService().getGroupMessages(widget.groupId);
    } else {
      chats = firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('removed_meets')
          .doc(widget.groupId)
          .collection('messages')
          .orderBy('time', descending: true)
          .snapshots();
    }
    setState(() {});
  }

  Future getUsers() async {
    awaitUsers = true;
    DocumentReference meet = firebaseFirestore
        .collection('meets')
        .doc(widget.groupId);
    usersInMeet = meet.snapshots();
    DocumentSnapshot data = await meet.get();
    Map mapData = data.data() as Map;
    meetDescription = mapData['description']?.toString() ?? '';
    for (int i = 0; i < mapData['users'].length; i++) {
      var user = await firebaseFirestore
          .collection('users')
          .doc(mapData['users'][i])
          .get();
      if (user.data() == null) continue;
      userInfo.add(
        UserInfo(
          user['fullName'],
          user['age'].toString(),
          user['city'],
          user['profilePic'],
          user['группа'],
          user['uid'],
          user.data() as Map,
        ),
      );
    }
    userWOutN = mapData['usersWithoutNotification'] ?? [];
    checkNotification();
    setState(() {
      awaitUsers = false;
    });
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                controller: ScrollController(),
                reverse: true,
                padding: EdgeInsets.only(
                  bottom: 70,
                  top: meetDescription.isNotEmpty ? 90 : 16,
                ),
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  UserInfo senderData = UserInfo('', '', '', '', '', '', {});
                  if (!awaitUsers) {
                    for (int i = 0; i < userInfo.length; i++) {
                      if (userInfo[i].uid ==
                          snapshot.data.docs[index]['sender']) {
                        senderData = userInfo[i];
                        break;
                      } else {}
                    }
                  }
                  return MessageTile(
                    avatar: userInfo.isNotEmpty
                        ? userImageWithCircle(
                            senderData.imageUrl,
                            senderData.group,
                            false,
                            50.0,
                            50.0,
                          )
                        : Container(),
                    name: snapshot.data.docs[index]['name'],
                    sender: snapshot.data.docs[index]['sender'],
                    chatId: widget.groupId,
                    message: snapshot.data.docs[index],
                    sentByMe:
                        firebaseAuth.currentUser!.uid ==
                        snapshot.data.docs[index]['sender'],
                    isRead: true,
                    isChat: false,
                  );
                },
              )
            : Container();
      },
    );
  }

  void sendMessage() async {
    DocumentSnapshot doc = await firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .get();
    String name = doc.get('fullName');
    Map<String, dynamic> chatMessageMap = {
      'message': messageController.text,
      'sender': firebaseAuth.currentUser!.uid,
      'avatar': firebaseAuth.currentUser!.photoURL,
      'group': doc.get('группа'),
      'name': name,
      'time': DateTime.now(),
    };

    DatabaseService().sendMessageGroup(widget.groupId, chatMessageMap);
    if (!awaitUsers) {
      addNotification();
    }
    setState(() {
      messageController.clear();
    });
  }

  void addNotification() async {
    List users = widget.users;
    users.removeWhere((element) => element == firebaseAuth.currentUser!.uid);
    Map notification = {
      'isChat': false,
      'groupId': widget.groupId,
      'groupName': widget.groupName,
      'users': widget.users,
      'isUserJoin': widget.isUserJoin,
      'message':
          '${firebaseAuth.currentUser!.displayName}: ${messageController.text}',
    };
    String token = '';

    for (int i = 0; i < users.length; i++) {
      if (!userWOutN.contains(users[i])) {
        var doc = await firebaseFirestore
            .collection('TOKENS')
            .doc(users[i])
            .get();
        token = doc.get('token');
        NotificationsService().sendPushMessageGroup(
          token,
          notification,
          widget.groupName,
          1,
          widget.groupId,
        );
      }
    }
  }

  Future<bool> onBackPress() {
    return Future.value(false);
  }

  void joinUser(String uid, String groupID) {
    widget.users.add(uid);
    firebaseFirestore.collection('meets').doc(groupID).update({
      'users': widget.users,
    });
  }
}
