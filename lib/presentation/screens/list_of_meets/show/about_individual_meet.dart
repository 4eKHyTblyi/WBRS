// ignore_for_file: unnecessary_string_escapes, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wbrs/app/helper/global.dart';
import 'package:wbrs/app/helper/helper_function.dart';
import 'package:wbrs/presentation/screens/list_of_users/show/somebody_profile.dart';
import 'package:wbrs/presentation/screens/chat_screen/chatscreen.dart';
import 'package:wbrs/app/widgets/widgets.dart';

import '../../../../service/database_service.dart';
import '../../../../service/notifications.dart';
import '../../edit_meet/edit_meet.dart';

class AboutIndividualMeet extends StatelessWidget {
  final AsyncSnapshot snapshot;
  final int index;
  final DocumentSnapshot doc;
  const AboutIndividualMeet({
    super.key,
    required this.snapshot,
    required this.index,
    required this.doc, // Pass myUid as a required parameter
  });

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

  @override
  Widget build(BuildContext context) {
    String myUid = firebaseAuth.currentUser!.uid;
    bool isMeAdmin = doc.id == myUid;
    addNotification() async {
      Map notification = {
        'isChat': false,
        'chatId': doc.id,
        'message':
            '${firebaseAuth.currentUser!.displayName} принял приглашение в группу',
      };
      String token = '';
      var meet = snapshot.data.docs[index];

      var data = await firebaseFirestore
          .collection('TOKENS')
          .doc(meet['admin'])
          .get();
      token = data.get('token');
      NotificationsService().sendPushMessageGroup(
        token,
        notification,
        meet['name'],
        1,
        meet.id,
      );
    }

    return Stack(
      children: [
        Image.asset(
          'assets/fon.jpg',
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Colors.white.withValues(alpha: 0.8),
            ),
            actions: [
              isMeAdmin
                  ? IconButton(
                      onPressed: () {
                        nextScreenReplace(
                          context,
                          EditMeet(meet: snapshot.data.docs[index]),
                        );
                      },
                      icon: const Icon(Icons.edit_calendar_outlined),
                    )
                  : const SizedBox(),
            ],
            backgroundColor: Colors.transparent,
            title: Text(
              snapshot.data.docs[index]['name'],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (doc.exists)
                    Card(
                      color: grey,
                      child: ListTile(
                        onTap: () {
                          if (isMeAdmin) {
                            return;
                          }
                          nextScreen(
                            context,
                            SomebodyProfile(
                              uid: doc.get('uid'),
                              photoUrl: doc.get('profilePic'),
                              name: doc.get('fullName'),
                              userInfo: doc.data() as Map,
                            ),
                          );
                        },
                        tileColor: Colors.transparent,
                        title: Text(
                          doc.get('fullName'),
                          style: const TextStyle(color: Colors.white),
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: userImageWithCircle(
                            doc.get('profilePic'),
                            doc.get('группа'),
                            false,
                            58.0,
                            58.0,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              '${doc.get('age')} ${doc.get('age') % 10 == 0
                                  ? 'лет'
                                  : doc.get('age') % 10 == 1
                                  ? 'год'
                                  : doc.get('age') % 10 == 5
                                  ? 'лет'
                                  : 'года'}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              "Город: ${doc.get('city')}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Детали встречи',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Описание: ${snapshot.data.docs[index]['description']}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Дата и время: ${snapshot.data.docs[index]['datetime']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Город: ${snapshot.data.docs[index]['city']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 50),
                  isMeAdmin
                      ? const SizedBox.shrink()
                      : snapshot.data.docs[index]['users'].contains(
                          firebaseAuth.currentUser!.uid,
                        )
                      ? const Center(
                          child: Text(
                            'Вы приняли приглашение на встречу',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: grey,
                            ),
                            onPressed: () async {
                              DocumentReference meet = firebaseFirestore
                                  .collection('meets')
                                  .doc(snapshot.data.docs[index].id);
                              List users = await meet.get().then(
                                (value) => value['users'],
                              );
                              meet.update({
                                'users': users + [myUid],
                              });
                              String chatID = '';
                              bool haveChat = false;
                              String uid = await meet.get().then(
                                (value) => value['admin'],
                              );
                              DocumentSnapshot userDoc = await firebaseFirestore
                                  .collection('users')
                                  .doc(uid)
                                  .get();
                              String name = userDoc.get('fullName');
                              String photoUrl = userDoc.get('profilePic');
                              await firebaseFirestore
                                  .collection('chats')
                                  .where(
                                    'user1',
                                    isEqualTo:
                                        FirebaseAuth.instance.currentUser!.uid,
                                  )
                                  .where('user2', isEqualTo: uid)
                                  .get()
                                  .then((QuerySnapshot snapshot) {
                                    if (snapshot.docs.isEmpty) {
                                    } else {
                                      haveChat = true;
                                      chatID = snapshot.docs[0].id;
                                    }
                                  });
                              await firebaseFirestore
                                  .collection('chats')
                                  .where(
                                    'user2',
                                    isEqualTo:
                                        FirebaseAuth.instance.currentUser!.uid,
                                  )
                                  .where('user1', isEqualTo: uid)
                                  .get()
                                  .then((QuerySnapshot snapshot) {
                                    if (snapshot.docs.isEmpty) {
                                    } else {
                                      haveChat = true;
                                      chatID = snapshot.docs[0].id;
                                    }
                                  });
                              addNotification();
                              if (haveChat == false) {
                                chatID = getChatRoomIdByUsernames(
                                  FirebaseAuth.instance.currentUser!.displayName
                                      .toString(),
                                  name,
                                );
                                Map<String, dynamic> chatRoomInfoMap = {
                                  'user1': FirebaseAuth
                                      .instance
                                      .currentUser!
                                      .uid
                                      .toString(),
                                  'user2': doc.id,
                                  'user1Nickname': FirebaseAuth
                                      .instance
                                      .currentUser!
                                      .displayName,
                                  'user2Nickname': name,
                                  'user1_image': FirebaseAuth
                                      .instance
                                      .currentUser!
                                      .photoURL,
                                  'user2_image': photoUrl,
                                  'lastMessage': '',
                                  'lastMessageSendBy': '',
                                  'lastMessageSendTs': DateTime.now(),
                                  'unreadMessage': 0,
                                  'chatId': chatID,
                                };
                                await DatabaseService().createChatRoom(
                                  getChatRoomIdByUsernames(
                                    firebaseAuth.currentUser!.displayName
                                        .toString(),
                                    name,
                                  ),
                                  chatRoomInfoMap,
                                );
                                DatabaseService().addChat(
                                  firebaseAuth.currentUser!.uid,
                                  chatID,
                                );
                                DatabaseService().addChatSecondUser(
                                  uid,
                                  chatID,
                                );
                                DatabaseService()
                                    .addMessage(chatID, 'to${meet.id}', {
                                      'message': 'Принял приглашение',
                                      'type': 'text',
                                      'isRead': false,
                                      'sendBy': FirebaseAuth
                                          .instance
                                          .currentUser!
                                          .displayName,
                                      'sendByID': FirebaseAuth
                                          .instance
                                          .currentUser!
                                          .uid,
                                      'ts':
                                          DateTime.now().millisecondsSinceEpoch,
                                    })
                                    .then((value) {
                                      Map<String, dynamic> lastMessageInfoMap =
                                          {
                                            'lastMessage': 'Принял приглашение',
                                            'lastMessageSendTs': DateTime.now(),
                                            'lastMessageSendBy': FirebaseAuth
                                                .instance
                                                .currentUser!
                                                .displayName,
                                            'lastMessageSendByID': FirebaseAuth
                                                .instance
                                                .currentUser!
                                                .uid,
                                          };

                                      DatabaseService().updateLastMessageSend(
                                        chatID,
                                        lastMessageInfoMap,
                                      );
                                    });
                              } else {
                                DatabaseService()
                                    .addMessage(chatID, 'to${meet.id}', {
                                      'message': 'Принял приглашение',
                                      'type': 'text',
                                      'isRead': false,
                                      'sendBy': FirebaseAuth
                                          .instance
                                          .currentUser!
                                          .displayName,
                                      'sendByID': FirebaseAuth
                                          .instance
                                          .currentUser!
                                          .uid,
                                      'ts': DateTime.now(),
                                    })
                                    .then((value) {
                                      Map<String, dynamic> lastMessageInfoMap =
                                          {
                                            'lastMessage': 'Принял приглашение',
                                            'lastMessageSendTs': DateTime.now(),
                                            'lastMessageSendBy': FirebaseAuth
                                                .instance
                                                .currentUser!
                                                .displayName,
                                            'lastMessageSendByID': FirebaseAuth
                                                .instance
                                                .currentUser!
                                                .uid,
                                          };

                                      DatabaseService().updateLastMessageSend(
                                        chatID,
                                        lastMessageInfoMap,
                                      );
                                    });
                              }
                              nextScreenReplace(
                                context,
                                ChatScreen(
                                  chatId: chatID,
                                  chatWithUsername: name,
                                  id: FirebaseAuth.instance.currentUser!.uid,
                                  photoUrl: photoUrl,
                                ),
                              );
                            },
                            child: isMeAdmin
                                ? const SizedBox.shrink()
                                : const Text(
                                    'Принять приглашение на встречу',
                                    style: TextStyle(color: Colors.white),
                                  ),
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
}
