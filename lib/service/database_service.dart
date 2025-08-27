import 'package:cloud_firestore/cloud_firestore.dart';
<<<<<<< Updated upstream

import '../app/helper/global.dart';
import '../app/helper/helper_function.dart';
=======
import 'package:firebase_auth/firebase_auth.dart';
import 'package:messenger/helper/helper_function.dart';
import 'package:messenger/service/notifications.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // reference for our collections
  final CollectionReference userCollection =
      firebaseFirestore.collection('users');
  final CollectionReference chatCollection =
      firebaseFirestore.collection('chats');
  final CollectionReference groupCollection =
      firebaseFirestore.collection('meets');

  Future savingUserDataAfterRegister(
      String fullName,
      String email,
      String profilePic,
      int age,
      String rost,
      String city,
      bool deti,
      String hobbi,
      String about,
      String pol) async {
<<<<<<< Updated upstream
<<<<<<< Updated upstream
    firebaseAuth.currentUser!.updateDisplayName(fullName);
    firebaseAuth.currentUser!.updateEmail(email);
    return await userCollection.doc(firebaseAuth.currentUser!.uid).set({
      'fullName': fullName,
      'email': email,
      'balance': 27,
      'profilePic': profilePic,
      'uid': uid,
      'age': age,
      'rost': rost,
      'about': about,
      'hobbi': hobbi,
      'deti': deti,
      'temperament': '',
      'uid': firebaseAuth.currentUser!.uid,
      'city': city,
      'images': [],
      'pol': pol,
      'группа': '',
      'isUnVisible': false,
      'lastOnlineTS': DateTime.now(),
      'online': true,
      'status': 'active'
    });
  }

  Future updateUserData(String fullName, String email, int age, String about,
      String hobbi, String city, bool deti) async {
    return await userCollection.doc(firebaseAuth.currentUser!.uid).update({
      'fullName': fullName,
      'email': email,
      'age': age,
      'about': about,
      'hobbi': hobbi,
      'city': city,
      'deti': deti
    });
=======
    try {
      await FirebaseAuth.instance.currentUser!.updateDisplayName(fullName);
      await FirebaseAuth.instance.currentUser!.updateEmail(email);
      return await userCollection
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        "fullName": fullName,
        "email": email,
        "chats": [],
        "profilePic": "",
        "uid": FirebaseAuth.instance.currentUser!.uid,
        "age": age,
        "rost": rost,
        "about": about,
        "hobbi": hobbi,
        "deti": deti,
        "temperament": "",
        "city": city,
        "images": [],
        "pol": pol,
      });
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'savingUserDataAfterRegister');
      rethrow;
    }
  }

  Future updateUserData(String fullName, String email, int age, String about,
=======
    try {
      await FirebaseAuth.instance.currentUser!.updateDisplayName(fullName);
      await FirebaseAuth.instance.currentUser!.updateEmail(email);
      return await userCollection
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        "fullName": fullName,
        "email": email,
        "chats": [],
        "profilePic": "",
        "uid": FirebaseAuth.instance.currentUser!.uid,
        "age": age,
        "rost": rost,
        "about": about,
        "hobbi": hobbi,
        "deti": deti,
        "temperament": "",
        "city": city,
        "images": [],
        "pol": pol,
      });
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'savingUserDataAfterRegister');
      rethrow;
    }
  }

  Future updateUserData(String fullName, String email, int age, String about,
>>>>>>> Stashed changes
      String hobbi, String city) async {
    try {
      return await userCollection
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        "fullName": fullName,
        "email": email,
        "age": age,
        "about": about,
        "hobbi": hobbi,
        "city": city
      });
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'updateUserData');
      rethrow;
    }
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
  }

  // getting user data
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where('email', isEqualTo: email).get();
    return snapshot;
  }

  // get user groups
  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

<<<<<<< Updated upstream
<<<<<<< Updated upstream
  // getting the chats
=======
  // getting the chats messages stream for 1:1
>>>>>>> Stashed changes
  getChats(String chatId) async {
    return chatCollection
        .doc(chatId)
        .collection('messages')
        .orderBy('time')
=======
  // getting the chats messages stream for 1:1
  getChats(String chatId) async {
    return chatCollection
        .doc(chatId)
        .collection("messages")
        .orderBy("ts", descending: true)
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
        .snapshots();
  }

  // search
  searchByName(String userName) {
    return chatCollection.where('users[1]', isEqualTo: userName).get();
  }

  //function -> bool
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    try {
      DocumentReference userDocumentReference = userCollection.doc(uid);
      DocumentSnapshot documentSnapshot = await userDocumentReference.get();

<<<<<<< Updated upstream
<<<<<<< Updated upstream
    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains('${groupId}_$groupName')) {
      return true;
    } else {
=======
=======
>>>>>>> Stashed changes
      if (!documentSnapshot.exists) return false;
      
      List<dynamic> groups = documentSnapshot.get('groups') ?? [];
      return groups.contains("${groupId}_$groupName");
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'isUserJoined');
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
      return false;
    }
  }

  // toggling the group join/exit
  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    try {
      // doc reference
      DocumentReference userDocumentReference = userCollection.doc(uid);
      DocumentReference groupDocumentReference = groupCollection.doc(groupId);

      DocumentSnapshot documentSnapshot = await userDocumentReference.get();
      if (!documentSnapshot.exists) return;
      
      List<dynamic> groups = documentSnapshot.get('groups') ?? [];

<<<<<<< Updated upstream
<<<<<<< Updated upstream
    // if user has our groups -> then remove then or also in other part re join
    if (groups.contains('${groupId}_$groupName')) {
      await userDocumentReference.update({
        'groups': FieldValue.arrayRemove(['${groupId}_$groupName'])
      });
      await groupDocumentReference.update({
        'members': FieldValue.arrayRemove(['${uid}_$userName'])
      });
    } else {
      await userDocumentReference.update({
        'groups': FieldValue.arrayUnion(['${groupId}_$groupName'])
      });
      await groupDocumentReference.update({
        'members': FieldValue.arrayUnion(['${uid}_$userName'])
      });
    }
  }

  // send message
  sendMessage(String chatId, Map<String, dynamic> chatMessageData) async {
    chatCollection.doc(chatId).collection('messages').add(chatMessageData);
    chatCollection.doc(chatId).update({
      'recentMessage': chatMessageData['message'],
      'recentMessageSender': chatMessageData['sender'],
      'recentMessageTime': chatMessageData['time'].toString(),
    });
  }

  sendMessageGroup(String chatId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(chatId).collection('messages').add(chatMessageData);
    groupCollection.doc(chatId).update({
      'recentMessage': chatMessageData['message'],
      'recentMessageSender': chatMessageData['name'],
      'recentMessageTime': chatMessageData['time'].toString(),
    });
=======
      // if user has our groups -> then remove then or also in other part re join
      if (groups.contains("${groupId}_$groupName")) {
        await userDocumentReference.update({
          "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
        });
        await groupDocumentReference.update({
          "members": FieldValue.arrayRemove(["${uid}_$userName"])
        });
      } else {
        await userDocumentReference.update({
          "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
        });
        await groupDocumentReference.update({
          "members": FieldValue.arrayUnion(["${uid}_$userName"])
        });
      }
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'toggleGroupJoin');
      rethrow;
=======
      // if user has our groups -> then remove then or also in other part re join
      if (groups.contains("${groupId}_$groupName")) {
        await userDocumentReference.update({
          "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
        });
        await groupDocumentReference.update({
          "members": FieldValue.arrayRemove(["${uid}_$userName"])
        });
      } else {
        await userDocumentReference.update({
          "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
        });
        await groupDocumentReference.update({
          "members": FieldValue.arrayUnion(["${uid}_$userName"])
        });
      }
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'toggleGroupJoin');
      rethrow;
    }
  }

  // send message in 1:1 chat (awaited)
  Future<String?> sendMessage(String chatId, Map<String, dynamic> chatMessageData) async {
    try {
      final messages = chatCollection.doc(chatId).collection("messages");
      final String messageId = messages.doc().id;
      await messages.doc(messageId).set(chatMessageData);
      await chatCollection.doc(chatId).update({
        "recentMessage": chatMessageData['message'],
        "recentMessageSender": chatMessageData['sender'] ?? chatMessageData['sendBy'],
        "recentMessageTime": chatMessageData['time']?.toString() ?? chatMessageData['ts']?.toString(),
      });
      return null; // success
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'sendMessage');
      return e.toString();
    }
  }

  Future<String?> sendMessageGroup(String chatId, Map<String, dynamic> chatMessageData) async {
    try {
      await groupCollection.doc(chatId).collection("messages").add(chatMessageData);
      await groupCollection.doc(chatId).update({
        "recentMessage": chatMessageData['message'],
        "recentMessageSender": chatMessageData['sender'],
        "recentMessageTime": chatMessageData['time'].toString(),
      });

      var usersDoc = await groupCollection.doc(chatId).get();
      var users = usersDoc.get('users');

      for (int i = 0; i < users.length; i++) {
        if (users[i] != FirebaseAuth.instance.currentUser!.uid) {
          var doc = await FirebaseFirestore.instance
              .collection('TOKENS')
              .doc(users[i])
              .get();

          var snap = await FirebaseFirestore.instance
              .collection('users')
              .doc(users[i])
              .get();

          String token = doc.get('token');
          String name = snap.get('fullName');

          NotificationsService().sendPushMessage(
              token,
              chatMessageData['message'],
              name,
              1,
              FirebaseAuth.instance.currentUser!.photoURL,
              chatId);
        }
      }
      return null;
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'sendMessageGroup');
      return e.toString();
>>>>>>> Stashed changes
    }
  }

  // send message in 1:1 chat (awaited)
  Future<String?> sendMessage(String chatId, Map<String, dynamic> chatMessageData) async {
    try {
      final messages = chatCollection.doc(chatId).collection("messages");
      final String messageId = messages.doc().id;
      await messages.doc(messageId).set(chatMessageData);
      await chatCollection.doc(chatId).update({
        "recentMessage": chatMessageData['message'],
        "recentMessageSender": chatMessageData['sender'] ?? chatMessageData['sendBy'],
        "recentMessageTime": chatMessageData['time']?.toString() ?? chatMessageData['ts']?.toString(),
      });
      return null; // success
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'sendMessage');
      return e.toString();
    }
  }

  Future<String?> sendMessageGroup(String chatId, Map<String, dynamic> chatMessageData) async {
    try {
      await groupCollection.doc(chatId).collection("messages").add(chatMessageData);
      await groupCollection.doc(chatId).update({
        "recentMessage": chatMessageData['message'],
        "recentMessageSender": chatMessageData['sender'],
        "recentMessageTime": chatMessageData['time'].toString(),
      });

      var usersDoc = await groupCollection.doc(chatId).get();
      var users = usersDoc.get('users');

      for (int i = 0; i < users.length; i++) {
        if (users[i] != FirebaseAuth.instance.currentUser!.uid) {
          var doc = await FirebaseFirestore.instance
              .collection('TOKENS')
              .doc(users[i])
              .get();

          var snap = await FirebaseFirestore.instance
              .collection('users')
              .doc(users[i])
              .get();

          String token = doc.get('token');
          String name = snap.get('fullName');

          NotificationsService().sendPushMessage(
              token,
              chatMessageData['message'],
              name,
              1,
              FirebaseAuth.instance.currentUser!.photoURL,
              chatId);
        }
      }
      return null;
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'sendMessageGroup');
      return e.toString();
    }
>>>>>>> Stashed changes
  }

  Future<Stream<QuerySnapshot>> getUserByUserName(String username) async {
    return firebaseFirestore
        .collection('users')
        .where('username', isEqualTo: username)
        .snapshots();
  }

  createChatRoom(String chatRoomId, var chatRoomInfoMap) async {
    final snapShot =
        await firebaseFirestore.collection('chats').doc(chatRoomId).get();

    if (snapShot.exists) {
      // chatroom already exists
      return true;
    } else {
      // chatroom does not exists
      return firebaseFirestore
          .collection('chats')
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
    }
  }

  Future<QuerySnapshot> getUserInfo(String username) async {
    return await firebaseFirestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
  }

  getChatRoomIdByUserID(String a, String b) {
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

  Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId) async {
    return firebaseFirestore
        .collection('chats')
        .doc(chatRoomId)
<<<<<<< Updated upstream
<<<<<<< Updated upstream
        .collection('chats')
        .orderBy('ts', descending: true)
=======
=======
>>>>>>> Stashed changes
        .collection("messages")
        .orderBy("ts", descending: true)
>>>>>>> Stashed changes
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getGroupMessages(chatRoomId) async {
    return firebaseFirestore
        .collection('meets')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }

  Future<String> GetChatRoomId(String user1, String user2) async {
    String chatId = '';
    await firebaseFirestore
        .collection('chats')
        .where('chatId', isEqualTo: getChatRoomIdByUserID(user1, user2))
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isEmpty) {
        chatId = getChatRoomIdByUserID(user2, user1);
      } else {
        chatId = getChatRoomIdByUserID(user1, user2);
      }
    });
    return chatId;
  }

  Future<Stream<QuerySnapshot>> getChatRooms() async {
    String myUsername = HelperFunctions().getUserName().toString();
    return firebaseFirestore
        .collection('chats')
        //.orderBy("lastMessage", descending: true)
        .where('users', arrayContains: myUsername)
        .snapshots();
  }

  Future addMessage(String chatRoomId, String messageId, messageInfoMap) async {
    return firebaseFirestore
        .collection('chats')
        .doc(chatRoomId)
<<<<<<< Updated upstream
<<<<<<< Updated upstream
        .collection('chats')
=======
        .collection("messages")
>>>>>>> Stashed changes
=======
        .collection("messages")
>>>>>>> Stashed changes
        .doc(messageId)
        .set(messageInfoMap);
  }

  updateLastMessageSend(String chatRoomId, lastMessageInfoMap) {
    return firebaseFirestore
        .collection('chats')
        .doc(chatRoomId)
        .update(lastMessageInfoMap);
  }

  updateUnreadMessageCount(String chatRoomId) async {
<<<<<<< Updated upstream
<<<<<<< Updated upstream
    DocumentSnapshot count =
        await firebaseFirestore.collection('chats').doc(chatRoomId).get();
    int kolvo = count.get('unreadMessage') + 1;

    firebaseFirestore
        .collection('chats')
        .doc(chatRoomId)
        .update({'unreadMessage': kolvo});
  }

  Future addChat(String uid, String chatId) {
    return firebaseFirestore.collection('users').doc(uid).update({
      'chats': FieldValue.arrayUnion([chatId])
    });
  }

  Future addChatSecondUser(String uid, String chatId) {
    return firebaseFirestore.collection('users').doc(uid).update({
      'chats': FieldValue.arrayUnion([chatId])
    });
=======
    try {
      DocumentSnapshot count = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatRoomId)
          .get();
      
      if (!count.exists) return;
      
      int currentCount = count.get('unreadMessage') ?? 0;
      int newCount = currentCount + 1;

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatRoomId)
          .update({"unreadMessage": newCount});
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'updateUnreadMessageCount');
    }
  }

  Future addChat(String uid, String chatId) async {
    try {
      return await FirebaseFirestore.instance.collection("users").doc(uid).update({
        "chats": FieldValue.arrayUnion([chatId])
      });
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'addChat');
      rethrow;
    }
  }

=======
    try {
      DocumentSnapshot count = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatRoomId)
          .get();
      
      if (!count.exists) return;
      
      int currentCount = count.get('unreadMessage') ?? 0;
      int newCount = currentCount + 1;

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatRoomId)
          .update({"unreadMessage": newCount});
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'updateUnreadMessageCount');
    }
  }

  Future addChat(String uid, String chatId) async {
    try {
      return await FirebaseFirestore.instance.collection("users").doc(uid).update({
        "chats": FieldValue.arrayUnion([chatId])
      });
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'addChat');
      rethrow;
    }
  }

>>>>>>> Stashed changes
  Future addChatSecondUser(String uid, String chatId) async {
    try {
      return await FirebaseFirestore.instance.collection("users").doc(uid).update({
        "chats": FieldValue.arrayUnion([chatId])
      });
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'addChatSecondUser');
      rethrow;
    }
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
  }
}
