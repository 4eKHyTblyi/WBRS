// ignore_for_file: must_be_immutable, empty_catches, non_constant_identifier_names, avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messenger/pages/profile_edit_page.dart';
import 'package:messenger/pages/profiles_list.dart';
import 'package:messenger/pages/visiters.dart';
import 'package:messenger/service/auth_service.dart';
import 'package:messenger/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:messenger/widgets/widgets.dart';

import '../helper/global.dart';
import '../widgets/bottom_nav_bar.dart';

class ProfilePage extends StatefulWidget {
  String userName;
  String email;
  String about;
  String age;
  String rost;
  String city;
  String hobbi;
  bool deti;
  String pol;
  ProfilePage({
    Key? key,
    required this.email,
    required this.userName,
    required this.about,
    required this.age,
    required this.pol,
    required this.deti,
    required this.rost,
    required this.city,
    required this.hobbi,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  FirebaseStorage storage = FirebaseStorage.instance;
  String imageUrl = " ";
  XFile? _image;
  TextEditingController? name = TextEditingController();
  late User? user = FirebaseAuth.instance.currentUser;
  void pickUploadImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    Reference ref = FirebaseStorage.instance
        .ref()
        .child("profilepic${FirebaseAuth.instance.currentUser?.uid}.jpg");

    await ref.putFile(File(image!.path));
    ref.getDownloadURL().then((value) {
      setState(() {
        imageUrl = value;
      });
    });
  }

  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.green,
            )
          ]),
          child: Image.asset(
            "assets/fon.jpg",
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
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              "??????????????",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.bold),
            ),
          ),
          drawer: const MyDrawer(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 17),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      (FirebaseAuth.instance.currentUser!.photoURL == "" ||
                              FirebaseAuth.instance.currentUser!.photoURL ==
                                  null)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(100.0),
                              child: Image.asset(
                                "assets/profile.png",
                                fit: BoxFit.cover,
                                height: 100.0,
                                width: 100.0,
                              ))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(100.0),
                              child: Image.network(
                                FirebaseAuth.instance.currentUser!.photoURL
                                    .toString(),
                                fit: BoxFit.cover,
                                height: 200.0,
                                width: 200.0,
                              )),
                      // Positioned(
                      //   bottom: 0,
                      //     right: 4,
                      //
                      //     child: ClipOval(
                      //
                      //       child: Container(
                      //         color: Colors.orange,
                      //
                      //         width: 50,
                      //         height: 50,
                      //         child: IconButton(
                      //           onPressed: () async{
                      //
                      //             GlobalPol=widget.pol;
                      //             nextScreen(context,
                      //                 ProfilePageEdit(
                      //                   email: widget.email,
                      //                   userName: widget.userName,
                      //                   about: widget.about,
                      //                   age: widget.age,
                      //                   hobbi: widget.hobbi,
                      //                   deti: widget.deti,
                      //                   city: widget.city,
                      //                   rost:widget.rost ,
                      //                 ));
                      //           },
                      //
                      //           icon:
                      //           const Icon(Icons.create,color: Colors.white,size: 30,),
                      //         ),
                      //       ),
                      //     ),)
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
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
                                        color: Colors.white.withOpacity(0.5),
                                        spreadRadius: 3,
                                        blurRadius:
                                            7, // changes position of shadow
                                      ),
                                    ],
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(50.0))),
                                child: IconButton(
                                    onPressed: () {
                                      var visiters = FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(FirebaseAuth
                                              .instance.currentUser!.uid)
                                          .collection('visiters')
                                          .snapshots();
                                      nextScreen(
                                          context,
                                          MyVisitersPage(
                                            visiters: visiters,
                                          ));
                                    },
                                    icon: const Icon(
                                      Icons.info,
                                      size: 30,
                                      color: Colors.white,
                                    ))),
                            const Text(
                              "?????? ??????????",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14),
                            ),
                            const SizedBox(
                              height: 50,
                            )
                          ],
                        ),
                        //const SizedBox(width: 7,),
                        Column(
                          children: [
                            const SizedBox(
                              height: 30,
                            ),
                            Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                  color: Colors.orangeAccent,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.5),
                                      spreadRadius: 3,
                                      blurRadius:
                                          7, // changes position of shadow
                                    ),
                                  ],
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(50.0))),
                              child: IconButton(
                                onPressed: () {
                                  GlobalPol = widget.pol;
                                  nextScreen(
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
                                      ));
                                },
                                icon: const Icon(
                                  Icons.mode_edit_sharp,
                                  size: 35,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Text(
                              "???????????????? ??????????????",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 18),
                            )
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
                                        color: Colors.white.withOpacity(0.5),
                                        spreadRadius: 3,
                                        blurRadius:
                                            7, // changes position of shadow
                                      ),
                                    ],
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(50.0))),
                                child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedIndex = 2;
                                      });
                                      nextScreenReplace(
                                          context, ProfilesList());
                                    },
                                    icon: const Icon(
                                      Icons.person,
                                      size: 35,
                                      color: Colors.white,
                                    ))),
                            const Text(
                              "????????",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14),
                            ),
                            const SizedBox(
                              height: 50,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  CountImages == 0
                      ? Column(
                          children: [
                            const Text(
                              "?????? ????????????????????",
                              style: TextStyle(color: Colors.white),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                XFile? image = await ImagePicker()
                                    .pickImage(source: ImageSource.gallery);
                                setState(() {
                                  _image = image;
                                });

                                FirebaseStorage storage =
                                    FirebaseStorage.instance;
                                try {
                                  await storage
                                      .ref(
                                          'images-${FirebaseAuth.instance.currentUser!.displayName}')
                                      .putFile(File(_image!.path));
                                } on FirebaseException {}
                                var downloadUrl = await storage
                                    .ref(
                                        'images-${FirebaseAuth.instance.currentUser!.displayName}')
                                    .getDownloadURL();

                                AddImages(
                                    FirebaseAuth.instance.currentUser!.uid,
                                    downloadUrl);
                              },
                              style: const ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                      Colors.orangeAccent)),
                              child: const Text(
                                "???????????????? ????????????????????",
                                style: TextStyle(color: Colors.black),
                              ),
                            )
                          ],
                        )
                      : Column(
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
                                            bottomLeft: Radius.circular(15))),
                                    height: 300,
                                    child: InkWell(
                                        onTap: () {
                                          showDialog(
                                            builder: (context) => AlertDialog(
                                              backgroundColor:
                                                  Colors.transparent,
                                              insetPadding:
                                                  const EdgeInsets.all(2),
                                              title: Container(
                                                decoration:
                                                    const BoxDecoration(),
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Image.network(
                                                  Images[index],
                                                ),
                                              ),
                                            ),
                                            context: context,
                                          );
                                        },
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(right: 5),
                                          width: 100,
                                          child: Image.network(Images[index],
                                              fit: BoxFit.cover),
                                        )),
                                  );
                                },
                                itemCount: CountImages,
                              ),
                            ),
                            ElevatedButton(
                                onPressed: () async {
                                  XFile? image = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);
                                  setState(() {
                                    _image = image;
                                  });

                                  FirebaseStorage storage =
                                      FirebaseStorage.instance;
                                  try {
                                    await storage
                                        .ref(
                                            'images-${FirebaseAuth.instance.currentUser!.displayName}-${_image!.name}')
                                        .putFile(File(_image!.path));
                                  } on FirebaseException catch (e) {
                                    print(e);
                                  }
                                  var downloadUrl = await storage
                                      .ref(
                                          'images-${FirebaseAuth.instance.currentUser!.displayName}-${_image!.name}')
                                      .getDownloadURL();

                                  AddImages(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      downloadUrl);
                                },
                                style: const ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(
                                        Colors.orangeAccent)),
                                child: const Text(
                                  "???????????????? ????????????????????",
                                ))
                          ],
                        ),
                  // const SizedBox(height: 20,),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     const Text("??????", style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,color: Colors.white)),
                  //     Row(
                  //       children: [
                  //         Text(user!.displayName.toString(), style: const TextStyle(fontSize: 17,color: Colors.white)),
                  //       ],
                  //     )
                  //   ],
                  // ),
                  // const SizedBox(height: 20,),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     const Text("Email", style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,color: Colors.white)),
                  //     Text(user!.email.toString(), style: const TextStyle(fontSize: 17,color: Colors.white)),
                  //   ],
                  // ),
                  // const SizedBox(height: 20,),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     const Text("??????????????", style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,color: Colors.white)),
                  //     Text(widget.age.toString(),
                  //         style: const TextStyle(fontSize: 17,color: Colors.white)),
                  //   ],
                  // ),
                  // const SizedBox(height: 20,),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     const Text("????????????", style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,color: Colors.white)),
                  //   ],
                  // ),
                  // const SizedBox(height: 20,),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     const Text("????????", style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,color: Colors.white)),
                  //     Text(
                  //         widget.rost.toString(),
                  //         style: const TextStyle(fontSize: 17,color: Colors.white)),
                  //   ],
                  // ),
                  // const SizedBox(height: 20,),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     const Text("??????", style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,color: Colors.white)),
                  //     Text(
                  //         widget.pol.toString(),
                  //         style: const TextStyle(fontSize: 17,color: Colors.white)),
                  //   ],
                  // ),
                  // const SizedBox(height: 20,),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     const Text("?????????????? ??????????", style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,color: Colors.white)),
                  //     Text(
                  //         widget.deti
                  //             ?"????????"
                  //             :"??????",
                  //         style: const TextStyle(fontSize: 17,color: Colors.white)),
                  //   ],
                  // ),
                  // const SizedBox(height: 20,),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     const Text("??????????", style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,color: Colors.white)),
                  //     Text(
                  //         widget.city.toString(),
                  //         style: const TextStyle(fontSize: 17,color: Colors.white)),
                  //   ],
                  // ),
                  // const SizedBox(height: 20,),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     const Text("??????????", style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,color: Colors.white)),
                  //     Text(
                  //         widget.hobbi.toString(),
                  //         style: const TextStyle(fontSize: 17,color: Colors.white)),
                  //   ],
                  // ),
                  // const SizedBox(height: 20,),
                  // Container(
                  //   width: double.infinity,
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //
                  //       const Text("?? ????????", style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,color: Colors.white),textAlign: TextAlign.left),
                  //       const Padding(padding: EdgeInsets.only(bottom: 20.0)),
                  //       Column(
                  //
                  //         mainAxisAlignment: MainAxisAlignment.start,
                  //         children: [
                  //           Container(
                  //             child: Text(widget.about.toString(),
                  //               style: const TextStyle(fontSize: 17,color: Colors.white),textAlign: TextAlign.left,softWrap: true,),
                  //           ),
                  //         ],
                  //       )
                  //
                  //
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(height: 20,),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  AddImages(String uid, String url) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      "images": FieldValue.arrayUnion([url])
    });
  }
}
