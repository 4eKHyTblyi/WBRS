import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messenger/pages/profile_page.dart';
import 'package:messenger/service/auth_service.dart';
import 'package:messenger/service/database_service.dart';
import 'package:messenger/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:messenger/widgets/widgets.dart';
import 'package:messenger/helper/global.dart' as global;

import '../helper/global.dart';
import '../widgets/bottom_nav_bar.dart';




class ProfilePageEdit extends StatefulWidget {
  String userName;
  String email;
  String about;
  String age;
  String rost;
  String city;
  String hobbi;
  bool deti;
  ProfilePageEdit({Key? key,
    required this.email,
    required this.userName,
    required this.about,
    required this.age,
    required this.deti,
    required this.rost,
    required this.city,
    required this.hobbi,
  })
      : super(key: key);

  @override
  _ProfilePageEditState createState() => _ProfilePageEditState();
}

class _ProfilePageEditState extends State<ProfilePageEdit> {
  String? dropdownValue;
  FirebaseStorage storage = FirebaseStorage.instance;
  String imageUrl = " ";
  String chatIdThis="";
  XFile? _image;
  TextEditingController? name = TextEditingController();
  TextEditingController? age = TextEditingController();
  TextEditingController? email = TextEditingController();
  TextEditingController? about = TextEditingController();
  TextEditingController? hobbi = TextEditingController();
  TextEditingController? city = TextEditingController();
  String? deti;
  late User? user = FirebaseAuth.instance.currentUser;

  void pickUploadImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );


    Reference ref = FirebaseStorage.instance.ref().child(
        "profilepic${FirebaseAuth.instance.currentUser?.uid}.jpg");


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

    TextTheme tema=GoogleFonts.robotoMonoTextTheme(Theme.of(context).textTheme);

    return Stack(
      children: [
        Image.asset(
          "assets/fon.jpg",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),

        MaterialApp(
          theme: ThemeData(
            textTheme: tema
          ),
          home:Scaffold(

                bottomNavigationBar: const MyBottomNavigationBar(),
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: const Text(
                    "Редактирование профиляы",
                    style: TextStyle(
                        color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
                  ),
                ),
                drawer: const MyDrawer(),
                body: SingleChildScrollView(
                    child: Container(
                      height: MediaQuery.of(context).size.height+100,
                      decoration: const BoxDecoration(


                        image: DecorationImage(image: AssetImage("assets/fon.jpg"),fit: BoxFit.fitHeight)
                      ),
                      padding: const EdgeInsets.symmetric( vertical: 17),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                (_image == null) ?
                                (FirebaseAuth.instance.currentUser!.photoURL == "")
                                    ? ClipRRect(
                                    borderRadius: BorderRadius.circular(100.0),
                                    child: Image.asset(
                                      "assets/profile.png",
                                      fit: BoxFit.cover,
                                      height: 100.0,
                                      width: 100.0,))
                                    : ClipRRect(
                                    borderRadius: BorderRadius.circular(100.0),
                                    child: Image.network(
                                      FirebaseAuth.instance.currentUser!.photoURL.toString(),
                                      fit: BoxFit.cover,
                                      height: 150.0,
                                      width: 150.0,))
                                    : ClipRRect(
                                    borderRadius: BorderRadius.circular(100.0),
                                    child: Image.file(
                                      File(_image!.path),
                                      fit: BoxFit.cover,
                                      height: 150.0,
                                      width: 150.0,)),
                                Positioned(
                                  bottom: 0,
                                  right: 4,

                                  child: ClipOval(

                                    child: Container(
                                      color: Colors.orange,

                                      width: 50,
                                      height: 50,
                                      child: IconButton(
                                        onPressed: () async {
                                          final AuthName=FirebaseAuth.instance.currentUser!.displayName;
                                          var docs = await FirebaseFirestore.instance.collection('chats').where('user1',isEqualTo: AuthName).get();
                                          final int countUser1 = docs.size;

                                          var docs2 = await FirebaseFirestore.instance.collection('chats').where('user2',isEqualTo:AuthName )
                                              .get();
                                          final int countUser2 = docs2.size;
                                          // print(await FirebaseFirestore.instance.collection('chats').where('user2',isEqualTo: AuthName)
                                          //     .snapshots().length);

                                          XFile? image = await ImagePicker().pickImage(
                                              source: ImageSource.gallery);

                                          setState(() {
                                            _image = image;
                                          });

                                          FirebaseStorage storage = FirebaseStorage.instance;
                                          try {
                                            await
                                            storage.ref(
                                                'avatar-${FirebaseAuth.instance.currentUser!
                                                    .displayName}').putFile(File(_image!.path));
                                          } on FirebaseException catch (e) {
                                            print(e);
                                          }
                                            var downloadUrl = await storage.ref(
                                                'avatar-${FirebaseAuth.instance.currentUser!
                                                    .displayName}').getDownloadURL();
                                            await FirebaseAuth.instance.currentUser!
                                                .updatePhotoURL(downloadUrl.toString());
                                            await FirebaseFirestore.instance.collection(
                                                "users")
                                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                                .update(
                                                {'profilePic': downloadUrl}).then((value) => print("done"));










                                              for(int i=0;i<countUser1;i++){
                                                final AuthName=FirebaseAuth.instance.currentUser!.displayName;
                                                chatIdThis="";
                                                  FirebaseFirestore.instance.collection('chats').where('user1',isEqualTo: AuthName)
                                                  .snapshots()
                                                  .listen((data) {
                                                    chatIdThis="${data.docs[i].id}";
                                                    FirebaseFirestore.instance.collection('chats').doc(chatIdThis).update(
                                                        {'user1_image':downloadUrl});

                                                  });
                                              };
                                              for(int i=0;i<countUser2;i++){
                                                final AuthName=FirebaseAuth.instance.currentUser!.displayName;
                                                chatIdThis="";
                                                FirebaseFirestore.instance.collection('chats').where('user2',isEqualTo: AuthName)
                                                    .snapshots()
                                                    .listen((data) {
                                                      chatIdThis="${data.docs[i].id}";
                                                      FirebaseFirestore.instance.collection('chats').doc(chatIdThis).update(
                                                          {'user2_image':downloadUrl});
                                                    });
                                              };
                                          },

                                        icon:
                                        const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 30,),
                                      ),
                                    ),
                                  ),)

                              ],
                            ),

                            const SizedBox(height: 40,),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              width: double.infinity,
                              child: Column(
                                children: [
                                  const Padding(padding: EdgeInsets.only(bottom: 10.0)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Имя",style: TextStyle(fontSize:20,fontWeight: FontWeight.w700),),
                                        SizedBox(
                                          width: 150,
                                          child: TextField(
                                            textAlign: TextAlign.end,
                                            style: const TextStyle(color: Colors.grey,),
                                            onSubmitted: (name){
                                              widget.userName=name.toString();

                                            },
                                            controller: name,
                                            decoration: InputDecoration(
                                              alignLabelWithHint: false,
                                              border: InputBorder.none,
                                              hintText: widget.userName,
                                              hintStyle: const TextStyle(color: Colors.black,fontWeight: FontWeight.w400,fontSize: 18),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Padding(padding: EdgeInsets.only(bottom: 10.0)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Возраст",style: TextStyle(fontSize:20,fontWeight: FontWeight.w700),),
                                        SizedBox(
                                          width: 150,
                                          child: TextField(
                                            textAlign: TextAlign.end,
                                            style: const TextStyle(color: Colors.grey,),
                                            keyboardType: TextInputType.number,
                                            onSubmitted: (age){
                                              widget.age=age.toString();
                                            },
                                            controller: age,
                                            decoration: InputDecoration(
                                              hintText: widget.age,
                                              hintStyle: const TextStyle(color: Colors.black),
                                              alignLabelWithHint: false,
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Padding(padding: EdgeInsets.only(bottom: 10.0)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Рост",style: TextStyle(fontSize:20,fontWeight: FontWeight.w700),),
                                        SizedBox(
                                          width: 150,
                                          child: TextField(
                                            textAlign: TextAlign.end,
                                            style: const TextStyle(color: Colors.grey,),
                                            onSubmitted: (email){
                                              widget.rost=email.toString();
                                            },
                                            controller: email,
                                            decoration: InputDecoration(
                                              hintText: widget.rost,
                                              hintStyle: const TextStyle(color: Colors.black),
                                              alignLabelWithHint: false,
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Padding(padding: EdgeInsets.only(bottom: 10.0)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("О себе",style: TextStyle(fontSize:20,fontWeight: FontWeight.w700),),
                                        SizedBox(
                                          width: 150,
                                          child: TextField(
                                            minLines: 1,
                                            maxLines: 5,
                                            style: const TextStyle(color: Colors.white),
                                            onSubmitted: (about){
                                              widget.about=about.toString();
                                            },
                                            controller: about,
                                            decoration: InputDecoration(
                                              hintText: widget.about,
                                              hintStyle: const TextStyle(color: Colors.black),
                                              alignLabelWithHint: false,
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Padding(padding: EdgeInsets.only(bottom: 10.0)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Хобби",style: TextStyle(fontSize:20,fontWeight: FontWeight.w700),),
                                        SizedBox(
                                          width: 150,
                                          child: TextField(
                                            textAlign: TextAlign.end,
                                            style: const TextStyle(color: Colors.grey,),
                                            onSubmitted: (about){
                                              widget.hobbi=about.toString();
                                            },
                                            controller: hobbi,
                                            decoration: InputDecoration(
                                              hintText: widget.hobbi,
                                              hintStyle: const TextStyle(color: Colors.black),
                                              alignLabelWithHint: false,
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Padding(padding: EdgeInsets.only(bottom: 10.0)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Город",style: TextStyle(fontSize:20,fontWeight: FontWeight.w700),),
                                        SizedBox(
                                          width: 150,
                                          child: TextField(
                                            textAlign: TextAlign.end,
                                            style: const TextStyle(color: Colors.grey,),
                                            onSubmitted: (city){
                                              widget.city=city.toString();
                                            },
                                            controller: city,
                                            decoration: InputDecoration(
                                              hintText: widget.city,
                                              hintStyle: const TextStyle(color: Colors.black),
                                              alignLabelWithHint: false,
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Padding(padding: EdgeInsets.only(bottom: 10.0)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Наличие детей",style: TextStyle(fontSize:20,fontWeight: FontWeight.w700),),
                                        SizedBox(
                                          width: 50,

                                          child: DropdownButton<String>(
                                            focusColor: Colors.black,

                                            //
                                            items: <String>['да', 'нет'].map((String value) {
                                              return DropdownMenuItem<String>(

                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                            onChanged: (String? value){
                                              setState(() {
                                                deti=value.toString();
                                              });
                                            },
                                            value: deti,


                                            style: const TextStyle(color: Color.fromRGBO(128, 128, 128, 1),),
                                            hint: const Text("нет",style: TextStyle(color: Colors.black),),
                                            dropdownColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                            ),
                            const SizedBox(height: 20,),
                            ElevatedButton(

                              onPressed: (){

                                setState(() {
                                  DatabaseService().updateUserData(
                                      widget.userName,
                                      widget.email,
                                      int.parse(widget.age),
                                      widget.about,
                                      widget.hobbi,
                                      widget.city
                                  );
                                  FirebaseAuth.instance.currentUser!.updateDisplayName(widget.userName);
                                  global.GlobalAge=widget.age;
                                  global.GlobalAbout=widget.about;
                                });
                                nextScreenReplace(context,
                                    ProfilePage(
                                      email: widget.email,
                                      userName: widget.userName,
                                      about: widget.about,
                                      age: widget.age,
                                      hobbi: widget.hobbi,
                                      deti: widget.deti,
                                      city: widget.city,
                                      rost:widget.rost ,
                                      pol: GlobalPol.toString(),
                                    ));

                              },
                              child: const Text("Сохранить",style: TextStyle(fontSize:20,),),
                              style: const ButtonStyle(
                                padding: MaterialStatePropertyAll(EdgeInsets.all(10.0)),
                                backgroundColor: MaterialStatePropertyAll(Colors.green),
                              ),),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}