// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wbrs/app/helper/global.dart';
import 'package:wbrs/app/helper/helper_function.dart';
import 'package:wbrs/presentation/screens/auth/register_screen/register_page.dart';
import 'package:wbrs/presentation/screens/home/home_page.dart';
import 'package:wbrs/service/auth_service.dart';
import 'package:wbrs/app/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isChecked = false;
  bool _isVisible = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String email = '';
  String password = '';
  bool _isLoading = false;

  TextEditingController resetPasswordEmail = TextEditingController();
  AuthService authService = AuthService();

  @override
  void initState() {
    _loadUserEmailPassword();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.black,
            )
          ]),
          child: Image.asset(
            'assets/fon2.jpg',
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            color: grey,
            colorBlendMode: BlendMode.modulate,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor),
                )
              : Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 80),
                      child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              const Text(
                                'LRS',
                                style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 10),
                              const Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    image: AssetImage('assets/logo.png'),
                                    width: 40,
                                  ),
                                  Text(
                                    ' Lasting relationships',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                  'Зарегестрируйтесь и знакомьтесь прямо сейчас!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white)),
                              const SizedBox(
                                height: 50,
                              ),
                              TextFormField(
                                controller: _emailController,
                                style: const TextStyle(color: Colors.white),
                                decoration: textInputDecoration.copyWith(
                                    labelStyle:
                                        const TextStyle(color: Colors.white),
                                    labelText: 'Email',
                                    prefixIcon: Icon(
                                      Icons.email,
                                      color: Theme.of(context).primaryColor,
                                    )),
                                onChanged: (val) {
                                  setState(() {
                                    email = val;
                                  });
                                },

                                // check tha validation
                                validator: (val) {
                                  return RegExp(
                                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#\$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                          .hasMatch(val!)
                                      ? null
                                      : 'Введите корректный email';
                                },
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: _passwordController,
                                style: const TextStyle(color: Colors.white),
                                cursorColor: Colors.white,
                                obscureText: _isVisible,
                                decoration: textInputDecoration.copyWith(
                                    suffix: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _isVisible = !_isVisible;
                                          });
                                        },
                                        icon: Icon(
                                            _isVisible
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: Colors.white)),
                                    fillColor: Colors.white,
                                    labelStyle:
                                        const TextStyle(color: Colors.white),
                                    labelText: 'Пароль',
                                    prefixIcon: Icon(
                                      Icons.lock,
                                      color: Theme.of(context).primaryColor,
                                    )),
                                validator: (val) {
                                  if (val!.length < 6) {
                                    return 'Пароль должен содержать 6 символов';
                                  } else {
                                    return null;
                                  }
                                },
                                onChanged: (val) {
                                  setState(() {
                                    password = val;
                                  });
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        height: 24.0,
                                        width: 24.0,
                                        child: Theme(
                                            data: ThemeData(
                                                unselectedWidgetColor:
                                                    const Color.fromARGB(
                                                        255,
                                                        255,
                                                        179,
                                                        15) // Your color
                                                ),
                                            child: Checkbox(
                                              activeColor: const Color.fromARGB(
                                                  255, 247, 175, 21),
                                              value: _isChecked,
<<<<<<< Updated upstream:lib/presentation/screens/auth/login_screen/login_page.dart
<<<<<<< Updated upstream:lib/presentation/screens/auth/login_screen/login_page.dart
                                              onChanged: ((value) {}),
=======
=======
>>>>>>> Stashed changes:lib/pages/auth/login_page.dart
                                              onChanged: _isLoading
                                                  ? null
                                                  : ((value) {
                                                      _handleRemeberme(
                                                          value ?? false);
                                                    }),
<<<<<<< Updated upstream:lib/presentation/screens/auth/login_screen/login_page.dart
>>>>>>> Stashed changes:lib/pages/auth/login_page.dart
=======
>>>>>>> Stashed changes:lib/pages/auth/login_page.dart
                                            ))),
                                    const SizedBox(width: 10.0),
                                    const Text('Запомнить меня',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontFamily: 'Rubic'))
                                  ]),
                              const SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      //primary: Theme.of(context).primaryColor,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30))),
                                  child: const Text(
                                    'Вход',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
<<<<<<< Updated upstream:lib/presentation/screens/auth/login_screen/login_page.dart
<<<<<<< Updated upstream:lib/presentation/screens/auth/login_screen/login_page.dart
                                  onPressed: () async {
                                    try {
                                      final result =
                                          await InternetAddress.lookup(
                                              'example.com');
                                      if (result.isNotEmpty &&
                                          result[0].rawAddress.isNotEmpty) {
                                        login();
                                      }
                                    } on SocketException catch (_) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      if (context.mounted) {
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                const AlertDialog(
                                                  content: Text(
                                                      'Нет соединения с интернетом'),
                                                ));
                                      }
                                    }
                                  },
=======
=======
>>>>>>> Stashed changes:lib/pages/auth/login_page.dart
                                  onPressed: _isLoading
                                      ? null
                                      : () async {
                                          final connectivityResult = await Connectivity().checkConnectivity();
                                          if (connectivityResult == ConnectivityResult.none) {
                                            showSnackbar(context, Colors.red,
                                                'Нет подключения к интернету');
                                            return;
                                          }
                                          login();
                                        },
<<<<<<< Updated upstream:lib/presentation/screens/auth/login_screen/login_page.dart
>>>>>>> Stashed changes:lib/pages/auth/login_page.dart
=======
>>>>>>> Stashed changes:lib/pages/auth/login_page.dart
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              Text.rich(TextSpan(
                                text: 'Нет аккаунта? ',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: 'Регистрация',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          decoration: TextDecoration.underline),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          nextScreenReplace(
                                              context, const RegisterPage());
                                        }),
                                ],
                              )),
                              TextButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return Container(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(children: [
                                            TextFormField(
                                              validator: (val) {
                                                return RegExp(
                                                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#\$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                        .hasMatch(val!)
                                                    ? null
                                                    : 'Введите корректный email';
                                              },
                                              controller: resetPasswordEmail,
                                              decoration: const InputDecoration(
                                                  hintText: 'Email'),
                                            ),
                                            TextButton(
                                                onPressed: () async {
                                                  if (resetPasswordEmail.text !=
                                                      '') {
                                                    await firebaseAuth
                                                        .sendPasswordResetEmail(
                                                            email:
                                                                resetPasswordEmail
                                                                    .text);
                                                    if (context.mounted) {
                                                      showSnackbar(
                                                          context,
                                                          Colors.orangeAccent,
                                                          'На вашу электронную почту отправлено письмо с ссылкой для сброса пароля.');
                                                      Navigator.pop(context);
                                                    }
                                                  } else {
<<<<<<< Updated upstream:lib/presentation/screens/auth/login_screen/login_page.dart
<<<<<<< Updated upstream:lib/presentation/screens/auth/login_screen/login_page.dart
                                                    if (context.mounted) {
                                                      showSnackbar(
                                                          context,
                                                          Colors.red,
                                                          'Введите email.');
                                                    }
=======
                                                    showSnackbar(context,
                                                        Colors.red, 'Введите email.');
>>>>>>> Stashed changes:lib/pages/auth/login_page.dart
=======
                                                    showSnackbar(context,
                                                        Colors.red, 'Введите email.');
>>>>>>> Stashed changes:lib/pages/auth/login_page.dart
                                                  }
                                                },
                                                child: const Text(
                                                  'Сбросить пароль',
                                                  style: TextStyle(
                                                      color:
                                                          Colors.orangeAccent),
                                                ))
                                          ]),
                                        );
                                      },
                                    );
                                  },
                                  child: const Text(
                                    'Забыли пароль?',
                                    style:
                                        TextStyle(color: Colors.orangeAccent),
                                  ))
                            ],
                          )),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  login() async {
    _handleRememberMe(_isChecked);
    if(_formKey.currentState!=null){
      if (_formKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
        });
        try {
          authService
              .loginWithUserNameAndPassword(
              _emailController.text, _passwordController.text)
<<<<<<< Updated upstream:lib/presentation/screens/auth/login_screen/login_page.dart
<<<<<<< Updated upstream:lib/presentation/screens/auth/login_screen/login_page.dart
              .then((value) async {
            if (value == true) {
              selectedIndex = 1;
              await HelperFunctions.saveUserLoggedInStatus(true);
              if (context.mounted) {
                DocumentSnapshot data = await firebaseFirestore
                    .collection('users')
                    .doc(firebaseAuth.currentUser!.uid)
                    .get();

                if (data.exists) {
                  if (data.get('status') == 'blocked') {
                    showSnackbar(
                        context, Colors.red, 'Ваш аккаунт заблокирован');
                    await firebaseAuth.signOut();
                    nextScreenReplace(context, const LoginPage());
                  } else {
                    await firebaseFirestore
                        .collection('users')
                        .doc(firebaseAuth.currentUser!.uid)
                        .update({'online': value});
                    showSnackbar(context, Colors.green, 'Вы авторизовались');
                    nextScreenReplace(context, const HomePage());
                  }
                } else {
                  await firebaseAuth.currentUser!.delete();
                  showSnackbar(context, Colors.red, 'Ваш аккаунт удален');
                  nextScreenReplace(context, const LoginPage());
                }
              }
            } else {
              setState(() {
                _isLoading = false;
              });
              showSnackbar(context, Colors.red, value);
            }
=======
=======
>>>>>>> Stashed changes:lib/pages/auth/login_page.dart
          .then((value) async {
        if (value == true) {
          selectedIndex = 1;
          nextScreenReplace(context, const HomePage());
        } else {
          final String code = value?.toString() ?? 'unexpected-error';
          String message = 'Ошибка входа: $code';
          if (code == 'user-not-found') message = 'Пользователь не найден';
          if (code == 'wrong-password') message = 'Неверный пароль';
          if (code == 'invalid-email') message = 'Неверный формат email';
          if (code == 'user-disabled') message = 'Пользователь отключен';
          if (code == 'network-request-failed') message = 'Ошибка сети';
          if (code == 'too-many-requests') message = 'Слишком много попыток. Попробуйте позже';
          await FirebaseCrashlytics.instance.log('Login failed: $code');
          showSnackbar(context, Colors.red, message);
          setState(() {
            _isLoading = false;
>>>>>>> Stashed changes:lib/pages/auth/login_page.dart
          });
        } on Exception catch (e) {
          showSnackbar(context, Colors.red, e);
          _isLoading = false;
        }
      }else{
        setState(() {
          _isLoading = false;
        });
        showSnackbar(context, Colors.red, 'Введите данные');
      }
    }else {
      print(_formKey.currentState);
      setState(() {
        _isLoading = false;
      });
      showSnackbar(context, Colors.red, 'Произошла ошибка, пожалуйста обратитесь в поддержку.');
    }
  }

  void _handleRememberMe(bool value) {
    _isChecked = value;
    SharedPreferences.getInstance().then(
      (prefs) {
        prefs.setBool('remember_me', value);
        prefs.setString('email', _emailController.text);
        prefs.setString('password', _passwordController.text);
      },
    );
  }

  void _loadUserEmailPassword() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String email = prefs.getString('email') ?? '';
      String password = prefs.getString('password') ?? '';
      bool remeberMe = prefs.getBool('remember_me') ?? false;

      if (remeberMe) {
        setState(() {
          _isChecked = remeberMe;
        });
        _emailController.text = email;
        _passwordController.text = password;
      }
    } catch (e) {
      debugPrint(e as String?);
    }
  }
}
