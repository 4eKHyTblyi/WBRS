import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:wbrs/app/helper/global.dart';
import 'package:wbrs/app/helper/helper_function.dart';

class AuthService {
  Future<bool> loginWithUserNameAndPassword(String email, String password) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Ошибка входа в систему',
        information: ['email: $email', 'код_ошибки: ${e.code}'],
      );
      
      if (e.code == 'user-not-found') {
        return false;
      } else if (e.code == 'wrong-password') {
        return false;
      }
      return false;
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Неожиданная ошибка при входе',
        information: ['email: $email'],
      );
      return false;
    }
  }

  Future<bool> registerUserWithEmailAndPassword(
      String fullName, String email, String password) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Ошибка регистрации пользователя',
        information: ['email: $email', 'имя: $fullName', 'код_ошибки: ${e.code}'],
      );
      
      if (e.code == 'weak-password') {
        return false;
      } else if (e.code == 'email-already-in-use') {
        return false;
      }
      return false;
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        reason: 'Неожиданная ошибка при регистрации',
        information: ['email: $email', 'имя: $fullName'],
      );
      return false;
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
