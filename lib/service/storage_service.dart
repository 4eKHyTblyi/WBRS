// ignore_for_file: empty_catches, unused_catch_clause

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class Storage {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future<String?> uploadProfilePhoto(String filePath) async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File file = File(filePath);
    final String refPath = 'profiles/$uid/$fileName';
    try {
      await storage.ref(refPath).putFile(file);
      final String downloadUrl = await storage.ref(refPath).getDownloadURL();
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profilePic': downloadUrl,
      });
      // Optionally also update auth profile photo for consistency
      await FirebaseAuth.instance.currentUser!.updatePhotoURL(downloadUrl);
      return downloadUrl;
    } on firebase_core.FirebaseException catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'uploadProfilePhoto');
      return null;
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'uploadProfilePhoto');
      return null;
    }
  }

  Future<void> uploadFiles(String filePath, String fileName) async {
    File file = File(filePath);

    try {
      await storage
          .ref('files/${FirebaseAuth.instance.currentUser?.uid}/$fileName')
          .putFile(file);
    } on firebase_core.FirebaseException catch (e) {}
  }

  Future<String> downloadUrl(fileName) async {
    String downloadUrl = await storage
        .ref('files/${FirebaseAuth.instance.currentUser?.uid}/$fileName')
        .getDownloadURL();
    FirebaseAuth.instance.currentUser!.updatePhotoURL(downloadUrl);

    return downloadUrl;
  }
}
