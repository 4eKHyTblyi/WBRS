import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wbrs/app/helper/global.dart';
import 'package:wbrs/app/widgets/widgets.dart';

import '../helper/helper_function.dart';
import '../../presentation/screens/chat_screen/chatscreen.dart';

class ChatRoomList extends StatefulWidget {
  final QueryDocumentSnapshot snapshot;
  const ChatRoomList({super.key, required this.snapshot});

  @override
  State<ChatRoomList> createState() => _ChatRoomListState();
}

class _ChatRoomListState extends State<ChatRoomList> {
  List chats = [];
  var myUid = firebaseAuth.currentUser!.uid;
  late DocumentSnapshot otherUser;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String id = '', nick = '', photoUrl = '';

    return FutureBuilder(
      future: firebaseFirestore
          .collection('users')
          .doc(
            widget.snapshot.get('user1') == myUid
                ? widget.snapshot.get('user2')
                : widget.snapshot.get('user1'),
          )
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        } else {
          String group = '';
          DocumentSnapshot data = snapshot.data!;
          id = data.id;
          nick = data.exists ? data.get('fullName') : 'Удаленный пользователь';
          photoUrl = data.exists ? data.get('profilePic') : '';
          if (snapshot.data!.data() != null) {
            group = snapshot.data!.get('группа');
          }
          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40.0),
            ),
            subtitle: widget.snapshot.get('lastMessage') != ''
                ? Container(
                    padding: const EdgeInsets.only(right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            "${widget.snapshot.get("lastMessageSendByID") == myUid ? "Вы" : widget.snapshot.get("lastMessageSendBy")}: ${widget.snapshot.get("lastMessage")}",
                            maxLines: 2,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        widget.snapshot.get('lastMessageSendByID') != myUid
                            ? widget.snapshot.get('unreadMessage') != null
                                  ? widget.snapshot.get('unreadMessage') != 0
                                        ? CircleAvatar(
                                            backgroundColor: Colors.white,
                                            radius: 10,
                                            child: Text(
                                              widget.snapshot
                                                  .get('unreadMessage')
                                                  .toString(),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                          )
                                        : const SizedBox()
                                  : const SizedBox()
                            : const SizedBox(),
                      ],
                    ),
                  )
                : const Text(
                    'нет сообщений',
                    style: TextStyle(color: Colors.white),
                  ),
            title: Text(nick, style: const TextStyle(color: Colors.white)),
            onTap: () async {
              nextScreen(
                context,
                ChatScreen(
                  chatWithUsername: nick,
                  photoUrl: photoUrl,
                  id: id,
                  chatId: widget.snapshot.id,
                ),
              );
            },
            leading: userImageWithCircle(
              photoUrl,
              group,
              data.exists ? data.get('online') : false,
              50.0,
              50.0,
            ),
            tileColor: grey,
            contentPadding: const EdgeInsets.all(15.0),
          );
        }
      },
    );
  }
}
