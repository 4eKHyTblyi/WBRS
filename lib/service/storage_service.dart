import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> uploadProfilePhoto(File file) async {
    final String uid = _auth.currentUser!.uid;
    final String path = 'profiles/$uid/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      final ref = _storage.ref(path);
      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      // Update Firestore and Auth profile
      await _db.collection('users').doc(uid).update({'profilePic': url});
      await _auth.currentUser?.updatePhotoURL(url);

      return url;
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Ошибка загрузки фото профиля',
        information: ['path: $path'],
      );
      rethrow;
    }
  }

  Future<String> uploadUserFile(File file) async {
    final String uid = _auth.currentUser!.uid;
    final String path = 'files/$uid/${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
    try {
      final ref = _storage.ref(path);
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Ошибка загрузки файла пользователя',
        information: ['path: $path'],
      );
      rethrow;
    }
  }
} 