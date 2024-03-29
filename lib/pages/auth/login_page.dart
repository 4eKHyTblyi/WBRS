// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:messenger/helper/global.dart';
import 'package:messenger/helper/helper_function.dart';
import 'package:messenger/pages/auth/register_page.dart';
import 'package:messenger/pages/home_page.dart';
import 'package:messenger/service/auth_service.dart';
import 'package:messenger/service/database_service.dart';
import 'package:messenger/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final resetPasswordFormKey = GlobalKey<FormState>();

  bool _isChecked = false;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String email = "";
  String password = "";
  bool _isLoading = false;

  TextEditingController resetPasswordEmail = TextEditingController();
  AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserEmailPassword();
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
            "assets/fon2.jpg",
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            color: Colors.white.withOpacity(0.7),
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
                          key: formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              const Text(
                                "WBRS",
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
                                    "Well-built relationships",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                  "Зарегестрируйтесь и знакомьтесь прямо сейчас!",
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
                                    labelText: "Email",
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
                                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                          .hasMatch(val!)
                                      ? null
                                      : "Введите корректный email";
                                },
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: _passwordController,
                                style: const TextStyle(color: Colors.white),
                                cursorColor: Colors.white,
                                obscureText: true,
                                decoration: textInputDecoration.copyWith(
                                    fillColor: Colors.white,
                                    labelStyle:
                                        const TextStyle(color: Colors.white),
                                    labelText: "Пароль",
                                    prefixIcon: Icon(
                                      Icons.lock,
                                      color: Theme.of(context).primaryColor,
                                    )),
                                validator: (val) {
                                  if (val!.length < 6) {
                                    return "Пароль должен содержать 6 символов";
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
                                              onChanged: ((value) {
                                                _handleRemeberme(
                                                    value ?? false);
                                              }),
                                            ))),
                                    const SizedBox(width: 10.0),
                                    const Text("Запомнить меня",
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
                                    "Вход",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  onPressed: () async {
                                    try {
                                      final result =
                                          await InternetAddress.lookup(
                                              'example.com');
                                      if (result.isNotEmpty &&
                                          result[0].rawAddress.isNotEmpty) {
                                        login();
                                      }
                                    } on SocketException catch (_) {}
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text.rich(TextSpan(
                                text: "Нет аккаунта? ",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: "Регистрация",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          decoration: TextDecoration.underline),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          nextScreen(
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
                                                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                        .hasMatch(val!)
                                                    ? null
                                                    : "Введите корректный email";
                                              },
                                              controller: resetPasswordEmail,
                                              decoration: const InputDecoration(
                                                  hintText: 'Email'),
                                            ),
                                            TextButton(
                                                onPressed: () async {
                                                  if (resetPasswordEmail.text !=
                                                      '') {
                                                    await FirebaseAuth.instance
                                                        .sendPasswordResetEmail(
                                                            email:
                                                                resetPasswordEmail
                                                                    .text);
                                                    showSnackbar(
                                                        context,
                                                        Colors.orangeAccent,
                                                        'На вашу электронную почту отправлено письмо с ссылкой для сброса пароля.');
                                                    Navigator.pop(context);
                                                  } else {
                                                    showSnackbar(
                                                        context,
                                                        Colors.red,
                                                        'Введите email.');
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

  login() {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      authService
          .loginWithUserNameandPassword(
              _emailController.text, _passwordController.text)
          .then((value) {
        if (value == true) {
          selectedIndex = 1;
          nextScreenReplace(context, const HomePage());
        } else {
          showSnackbar(context, Colors.red, value);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  void _handleRemeberme(bool value) {
    _isChecked = value;
    SharedPreferences.getInstance().then(
      (prefs) {
        prefs.setBool("remember_me", value);
        prefs.setString('email', _emailController.text);
        prefs.setString('password', _passwordController.text);
      },
    );
    setState(() {
      _isChecked = value;
    });
  }

  void _loadUserEmailPassword() async {
    try {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      var _email = _prefs.getString("email") ?? "";
      var _password = _prefs.getString("password") ?? "";
      var _remeberMe = _prefs.getBool("remember_me") ?? false;
      if (_remeberMe) {
        setState(() {
          _isChecked = true;
        });
        _emailController.text = _email ?? "";
        _passwordController.text = _password ?? "";
      }
    } catch (e) {
      print(e);
    }
  }
}
