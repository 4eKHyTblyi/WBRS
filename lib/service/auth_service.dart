import 'package:flutter/material.dart';
import 'package:wbrs/app/helper/global.dart';
import 'package:wbrs/app/helper/helper_function.dart';
import 'package:firebase_auth/firebase_auth.dart';
<<<<<<< Updated upstream
=======
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes

class AuthService {
  // login
  Future loginWithUserNameAndPassword(String email, String password) async {
    try {
<<<<<<< Updated upstream
<<<<<<< Updated upstream
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
=======
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 10));
      await HelperFunctions.saveUserLoggedInStatus(true);
      return true;
=======
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 10));
      await HelperFunctions.saveUserLoggedInStatus(true);
      return true;
>>>>>>> Stashed changes
    } on FirebaseAuthException catch (e, st) {
      // Log detailed auth error to Crashlytics
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'loginWithUserNameandPassword');
      return e.code; // e.g., 'user-not-found', 'wrong-password', 'network-request-failed'
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'loginWithUserNameandPassword-unexpected');
      return 'unexpected-error';
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
    }
  }

  // register
  Future registerUserWithEmailAndPassword(
      String fullName, String email, String password) async {
    try {
<<<<<<< Updated upstream
<<<<<<< Updated upstream
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
=======
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 10));
      await HelperFunctions.saveUserLoggedInStatus(true);
      return true;
=======
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 10));
      await HelperFunctions.saveUserLoggedInStatus(true);
      return true;
>>>>>>> Stashed changes
    } on FirebaseAuthException catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'registerUserWithEmailandPassword');
      return e.code; // e.g., 'weak-password', 'email-already-in-use', 'network-request-failed'
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'registerUserWithEmailandPassword-unexpected');
      return 'unexpected-error';
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
    }
  }

  // signout
  Future signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInStatus(false);
      await HelperFunctions.saveUserEmailSF('');
      await HelperFunctions.saveUserNameSF('');
      await firebaseAuth.signOut();
<<<<<<< Updated upstream
<<<<<<< Updated upstream
    } catch (e) {
      debugPrint(e.toString());
=======
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'signOut');
>>>>>>> Stashed changes
=======
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'signOut');
>>>>>>> Stashed changes
    }
  }
}
