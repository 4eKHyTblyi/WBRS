import 'package:flutter/material.dart';
import 'package:wbrs/app/helper/global.dart';
import 'package:wbrs/app/helper/helper_function.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // login
  Future loginWithUserNameAndPassword(String email, String password) async {
    try {
      // ignore: unused_local_variable
      UserCredential user = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        debugPrint('No user found for that email.');

        return ('Нет пользователя с такой почтой.');
      } else if (e.code == 'wrong-password') {
        debugPrint('Wrong password provided for that user.');
        return ('Неверный пароль.');
      }
    }
  }

  // register
  Future registerUserWithEmailAndPassword(
      String fullName, String email, String password) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return ('Пароль слишком слабый.');
      } else if (e.code == 'email-already-in-use') {
        return ('Такой пользователь уже существует.');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // signout
  Future signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInStatus(false);
      await HelperFunctions.saveUserEmailSF('');
      await HelperFunctions.saveUserNameSF('');
      await firebaseAuth.signOut();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
