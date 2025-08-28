import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:wbrs/app/helper/global.dart';
import 'package:wbrs/app/helper/helper_function.dart';

class AuthService {
  Future<String> loginWithUserNameAndPassword(String email, String password) async {
    try {
      await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 10));
      // Success
      await HelperFunctions.saveUserLoggedInStatus(true);
      return 'ok';
    } on FirebaseAuthException catch (e) {
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Ошибка входа в систему',
        information: ['email: $email', 'код_ошибки: ${e.code}'],
      );
      return e.code; // e.g. user-not-found, wrong-password, network-request-failed
    } on TimeoutException catch (e) {
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Таймаут при входе',
        information: ['email: $email'],
      );
      return 'timeout';
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Неожиданная ошибка при входе',
        information: ['email: $email'],
      );
      return 'unexpected-error';
    }
  }

  Future<String> registerUserWithEmailAndPassword(
      String fullName, String email, String password) async {
    try {
      await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 10));
      await HelperFunctions.saveUserLoggedInStatus(true);
      firebaseAuth.currentUser?.updateDisplayName(fullName);
      return 'ok';
    } on FirebaseAuthException catch (e) {
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Ошибка регистрации пользователя',
        information: ['email: $email', 'имя: $fullName', 'код_ошибки: ${e.code}'],
      );
      return e.code; // weak-password, email-already-in-use, network-request-failed, etc
    } on TimeoutException catch (e) {
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Таймаут при регистрации',
        information: ['email: $email', 'имя: $fullName'],
      );
      return 'timeout';
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Неожиданная ошибка при регистрации',
        information: ['email: $email', 'имя: $fullName'],
      );
      return 'unexpected-error';
    }
  }

  Future<void> signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInStatus(false);
      await HelperFunctions.saveUserEmailSF('');
      await HelperFunctions.saveUserNameSF('');
      await firebaseAuth.signOut();
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Ошибка выхода из системы',
      );
    }
  }
}
