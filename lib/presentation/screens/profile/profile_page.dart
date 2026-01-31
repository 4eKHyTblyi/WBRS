// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wbrs/app/helper/global.dart';
import 'package:wbrs/app/helper/helper_function.dart';
import 'package:wbrs/presentation/screens/auth/login_screen/login_page.dart';
import 'package:wbrs/presentation/screens/edit_profile/profile_edit_page.dart';
import 'package:wbrs/presentation/screens/list_of_users/profiles_list.dart';
import 'package:wbrs/presentation/screens/list_of_visiters/visiters.dart';
import 'package:wbrs/service/auth_service.dart';
import 'package:wbrs/app/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:wbrs/app/widgets/show_image.dart';
import 'package:wbrs/app/widgets/widgets.dart';

import '../../../app/helper/global.dart' as global;
import '../../../app/widgets/bottom_nav_bar.dart';

class ProfilePage extends StatefulWidget {
  final String email;
  final String about;
  final String age;
  final String rost;
  final String city;
  final String hobbi;
  final String userName;
  final bool deti;
  final String pol;
  final String group;
  const ProfilePage({
    super.key,
    required this.email,
    required this.userName,
    required this.about,
    required this.age,
    required this.pol,
    required this.group,
    required this.deti,
    required this.rost,
    required this.city,
    required this.hobbi,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String imageUrl = ' ';
  TextEditingController? name = TextEditingController();

  final ImagePicker imagePicker = ImagePicker();
  List<XFile>? imageFileList = [];

  void selectImages() async {
    final List<XFile> selectedImages = await imagePicker.pickMultiImage(
      imageQuality: 50,
    );
    if (selectedImages.isNotEmpty) {
      imageFileList!.addAll(selectedImages);
      for (int i = 0; i < selectedImages.length; i++) {
        loadImage(selectedImages[i].name, selectedImages[i]);
      }
    }
    selectedImages.clear();
  }

  void pickUploadImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    Reference ref = FirebaseStorage.instance.ref().child(
      'profilepic${firebaseAuth.currentUser?.uid}.jpg',
    );

    await ref.putFile(File(image!.path));
    ref.getDownloadURL().then((value) {
      setState(() {
        imageUrl = value;
      });
    });
  }

  AuthService authService = AuthService();
  String password = '';
  String passwordConfirm = '';

  var currentUser = firebaseAuth.currentUser;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    name!.dispose();
    imageFileList!.clear();
    imageFileList = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(boxShadow: []),
          child: Image.asset(
            'assets/fon.jpg',
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            scale: 0.6,
          ),
        ),
        Scaffold(
          bottomNavigationBar: const MyBottomNavigationBar(),
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    backgroundColor: darkGrey,
                    context: context,
                    builder: (context) {
                      return Container(
                        height: MediaQuery.of(context).size.height,
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: SingleChildScrollView(
                            child: Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    style: const TextStyle(color: Colors.black),
                                    obscureText: true,
                                    decoration: textInputDecoration.copyWith(
                                      labelStyle: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      labelText: 'Введите пароль',
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
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
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    style: const TextStyle(color: Colors.black),
                                    obscureText: true,
                                    decoration: textInputDecoration.copyWith(
                                      labelStyle: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      labelText: 'Повторите пароль',
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    validator: (val) {
                                      if (val!.length < 6) {
                                        return 'Пароль должен содержать 6 символов';
                                      } else {
                                        if (val != password) {
                                          return 'Пароли не совпадают!';
                                        }
                                        return null;
                                      }
                                    },
                                    onChanged: (val) {
                                      setState(() {
                                        passwordConfirm = val;
                                      });
                                    },
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      if (formKey.currentState!.validate()) {
                                        try {
                                          await FirebaseAuth
                                              .instance
                                              .currentUser!
                                              .updatePassword(passwordConfirm);

                                          firebaseAuth.signOut();
                                          nextScreenReplace(
                                            context,
                                            const LoginPage(),
                                          );
                                          showSnackbar(
                                            context,
                                            Colors.green,
                                            'Пароль успешно изменен! Пожалуйста авторизуйтесь повторно.',
                                          );
                                        } on Exception catch (e) {
                                          showSnackbar(
                                            context,
                                            Colors.red,
                                            e.toString(),
                                          );
                                        }
                                      }
                                    },
                                    child: const Text(
                                      'Сменить пароль',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.more_horiz_rounded),
                splashRadius: 20,
              ),
            ],
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Профиль',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            automaticallyImplyLeading: true,
          ),
          drawer: const MyDrawer(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 17),
            child: SizedBox(
              width: double.infinity,
              child: currentUser != null
                  ? Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            StreamBuilder(
                              stream: firebaseFirestore
                                  .collection('users')
                                  .doc(currentUser!.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return userImageWithCircle(
                                    snapshot.data!['profilePic'],
                                    widget.group,
                                    snapshot.data!['online'],
                                  );
                                } else {
                                  return userImageWithCircle(
                                    '',
                                    widget.group,
                                    false,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Ваша группа: ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              widget.group,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Ваша баланс: ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              globalBalance.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Вам подходят: ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Column(children: getLikeGroup(widget.group)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 140,
                          child: Row(
                            //mainAxisSize: MainAxisSize.values.first,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.orangeAccent,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withValues(
                                            alpha: 0.5,
                                          ),
                                          spreadRadius: 3,
                                          blurRadius:
                                              7, // changes position of shadow
                                        ),
                                      ],
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(50.0),
                                      ),
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        var visiters = FirebaseFirestore
                                            .instance
                                            .collection('users')
                                            .doc(firebaseAuth.currentUser!.uid)
                                            .collection('visiters')
                                            .orderBy(
                                              'lastVisitTs',
                                              descending: true,
                                            )
                                            .snapshots();
                                        nextScreenReplace(
                                          context,
                                          MyVisitersPage(visiters: visiters),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.info,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    'Мои гости',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 50),
                                ],
                              ),
                              Column(
                                children: [
                                  const SizedBox(height: 30),
                                  Container(
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.orangeAccent,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withValues(
                                            alpha: 0.5,
                                          ),
                                          spreadRadius: 3,
                                          blurRadius:
                                              7, // changes position of shadow
                                        ),
                                      ],
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(50.0),
                                      ),
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        global.globalPol = widget.pol;
                                        nextScreenReplace(
                                          context,
                                          ProfilePageEdit(
                                            email: widget.email,
                                            userName: widget.userName,
                                            about: widget.about,
                                            age: widget.age,
                                            hobbi: widget.hobbi,
                                            deti: widget.deti,
                                            city: widget.city,
                                            rost: widget.rost,
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.mode_edit_sharp,
                                        size: 35,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    'Изменить профиль',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              //const SizedBox(width: 7,),
                              Column(
                                children: [
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.orangeAccent,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withValues(
                                            alpha: 0.5,
                                          ),
                                          spreadRadius: 3,
                                          blurRadius:
                                              7, // changes position of shadow
                                        ),
                                      ],
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(50.0),
                                      ),
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          global.selectedIndex = 2;
                                        });
                                        nextScreenReplace(
                                          context,
                                          ProfilesList(
                                            startPosition: 0,
                                            group: widget.group,
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.person,
                                        size: 35,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    'Люди',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 50),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'Фотографии',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        StreamBuilder(
                          stream: firebaseFirestore
                              .collection('users')
                              .doc(firebaseAuth.currentUser!.uid)
                              .collection('images')
                              .snapshots(),
                          builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.data != null) {
                              if (snapshot.data!.docs.length != 0) {
                                return ifImageSnapshotNotEmpty(snapshot);
                              } else {
                                return ifImageSnaphotEmpty(snapshot);
                              }
                            } else {
                              return ifImageSnaphotEmpty(snapshot);
                            }
                          },
                        ),
                        const Text(
                          'Подарки',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 20),
                        StreamBuilder(
                          stream: firebaseFirestore
                              .collection('users')
                              .doc(firebaseAuth.currentUser!.uid)
                              .snapshots(),
                          builder:
                              (
                                context,
                                AsyncSnapshot<DocumentSnapshot> snapshot,
                              ) {
                                if (snapshot.data != null) {
                                  Map docAsMap = snapshot.data!.data() as Map;
                                  if (docAsMap['presentedGifts'] != null) {
                                    if (docAsMap['presentedGifts'].length > 0) {
                                      return ifGiftsSnapshotNotEmtpry(
                                        docAsMap['presentedGifts'],
                                      );
                                    } else {
                                      return ifGiftsSnaphotEmpty(snapshot);
                                    }
                                  } else {
                                    return ifGiftsSnaphotEmpty(snapshot);
                                  }
                                } else {
                                  return ifGiftsSnaphotEmpty(snapshot);
                                }
                              },
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),
          ),
        ),
      ],
    );
  }

  ifImageSnapshotNotEmpty(AsyncSnapshot snapshot) {
    List urls = [];
    List initList = [];
    for (int i = 0; i < snapshot.data.docs.length; i++) {
      urls.add(snapshot.data.docs[i]['url']);
      initList.add(snapshot.data.docs[i]['url']);
    }
    urls.sort((a, b) {
      return a.toString() == firebaseAuth.currentUser!.photoURL
          ? -1
          : b.toString() == firebaseAuth.currentUser!.photoURL
          ? 1
          : 0;
    });

    return Column(
      children: [
        SizedBox(
          height: 100,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
                height: 300,
                child: InkWell(
                  onTap: () {
                    nextScreen(
                      context,
                      ShowImage(
                        urls: urls,
                        initList: initList,
                        index: index,
                        snapshot: snapshot,
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(urls[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                    width: 100,
                    child: const SizedBox(),
                  ),
                ),
              );
            },
            itemCount: urls.length,
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            selectImages();

            imageFileList!.clear();
          },
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.orangeAccent),
          ),
          child: const Text(
            'Добавить фотографии',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

  ifImageSnaphotEmpty(AsyncSnapshot snapshot) {
    return Column(
      children: [
        const Text('Нет фотографий', style: TextStyle(color: Colors.white)),
        ElevatedButton(
          onPressed: () async {
            selectImages();
          },
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.orangeAccent),
          ),
          child: const Text(
            'Добавить фотографии',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  loadImage(String name, XFile image) async {
    var time = DateTime.now();
    FirebaseStorage storage = FirebaseStorage.instance;

    await storage
        .ref('$name+$time+${firebaseAuth.currentUser!.uid}')
        .putFile(File(image.path));
    var downloadUrl = await storage
        .ref('$name+$time+${firebaseAuth.currentUser!.uid}')
        .getDownloadURL();

    await firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('images')
        .add({'url': downloadUrl});
  }

  ifGiftsSnapshotNotEmtpry(Map gifts) {
    List urlsList = gifts.keys.toList();
    List countList = gifts.values.toList();
    return Column(
      children: [
        SizedBox(
          height: 100,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
                height: 300,
                child: InkWell(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.only(right: 5),
                    width: 110,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(urlsList[index], fit: BoxFit.fitWidth),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.white),
                            ),
                            child: Text(
                              countList[index].toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            itemCount: gifts.length,
          ),
        ),
      ],
    );
  }

  ifGiftsSnaphotEmpty(AsyncSnapshot snapshot) {
    return const Column(
      children: [Text('Нет подарков', style: TextStyle(color: Colors.white))],
    );
  }
}
