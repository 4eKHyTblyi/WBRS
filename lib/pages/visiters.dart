// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messenger/pages/auth/somebody_profile.dart';
import 'package:messenger/widgets/drawer.dart';
import 'package:messenger/widgets/widgets.dart';

class MyVisitersPage extends StatefulWidget {
  Stream? visiters;
  MyVisitersPage({Key? key, required this.visiters}) : super(key: key);

  @override
  State<MyVisitersPage> createState() => _MyVisitersPageState();
}

class _MyVisitersPageState extends State<MyVisitersPage> {
  String MyUid = '';

  @override
  Widget build(BuildContext context) {
    Widget visitersList(AsyncSnapshot snapshot, int index) {
      return Card(
        child: ListTile(
          onTap: () async {
            var doc = await FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.docs[index]['uid'])
                .get();

            // ignore: use_build_context_synchronously
            nextScreen(
                context,
                SomebodyProfile(
                  uid: snapshot.data!.docs[index]['uid'],
                  photoUrl: snapshot.data!.docs[index]['photoUrl'],
                  name: snapshot.data!.docs[index]['fullName'],
                  userInfo: doc,
                ));
          },
          leading: SizedBox(
            height: 50,
            width: 50,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  snapshot.data!.docs[index]['photoUrl'],
                  fit: BoxFit.cover,
                )),
          ),
          title: Text(
            snapshot.data!.docs[index]['fullName'],
            style: const TextStyle(color: Colors.black),
          ),
          subtitle: Row(
            children: [
              int.parse(snapshot.data!.docs[index]['age']) % 10 == 0
                  ? Text('${snapshot.data!.docs[index]['age']} лет')
                  : int.parse(snapshot.data!.docs[index]['age']) % 10 == 1
                      ? Text('${snapshot.data!.docs[index]['age']} год')
                      : int.parse(snapshot.data!.docs[index]['age']) % 10 != 5
                          ? Text('${snapshot.data!.docs[index]['age']} года')
                          : Text('${snapshot.data!.docs[index]['age']} лет'),
              const SizedBox(
                width: 20,
              ),
              Text("Город: ${snapshot.data!.docs[index]['city']}")
            ],
          ),
          dense: false,
        ),
      );
    }

    return Stack(
      children: [
        Image.asset(
          "assets/fon.jpg",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          appBar: AppBar(
            title: const Text('Посетители страницы'),
            backgroundColor: Colors.transparent,
          ),
          backgroundColor: Colors.transparent,
          drawer: const MyDrawer(),
          body: SingleChildScrollView(
            child: StreamBuilder(
                stream: widget.visiters,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                      height: 700,
                      padding: const EdgeInsets.all(15),
                      child: const Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Пока на вашей странице не было гостей.",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 30),
                      height: 700,
                      child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (BuildContext context, index) {
                            return visitersList(snapshot, index);
                          }),
                    );
                  }
                }),
          ),
        ),
      ],
    );
  }
}