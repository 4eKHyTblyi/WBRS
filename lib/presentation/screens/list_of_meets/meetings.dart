// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wbrs/app/helper/global.dart';
import 'package:wbrs/app/helper/helper_function.dart';
import 'package:wbrs/presentation/screens/list_of_meets/show/about_individual_meet.dart';
import 'package:wbrs/presentation/screens/list_of_meets/show/about_meet.dart';
import 'package:wbrs/presentation/screens/create_meet/create_meet.dart';
import 'package:wbrs/app/widgets/bottom_nav_bar.dart';
import 'package:wbrs/app/widgets/drawer.dart';
import 'package:wbrs/app/widgets/widgets.dart';

import '../../../app/pages/filter_pages/cities.dart';

class MeetingPage extends StatefulWidget {
  const MeetingPage({super.key});

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  @override
  void initState() {
    super.initState();
    meets = firebaseFirestore
        .collection('meets')
        .orderBy('timeStamp', descending: true)
        .snapshots();
    if (meetCity != '') {
      meets = firebaseFirestore
          .collection('meets')
          .where('city', isEqualTo: meetCity)
          .orderBy('timeStamp', descending: true)
          .snapshots();
    }
  }

  TextEditingController city = TextEditingController(text: meetCity);
  Stream<QuerySnapshot>? meets;
  late int kolvo_users;

  @override
  void dispose() {
    super.dispose();
    city.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
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
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                onPressed: () {
                  nextScreenReplace(context, const CreateMeetPage());
                },
                icon: const Icon(Icons.add),
              ),
            ],
            title: const Text('Встречи', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.transparent,
          ),
          bottomNavigationBar: const MyBottomNavigationBar(),
          drawer: const MyDrawer(),
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(),
            child: Column(
              children: [
                TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      backgroundColor: grey,
                      context: context,
                      builder: (context) {
                        return Container(
                          padding: const EdgeInsets.all(15),
                          child: const Column(
                            children: [
                              Text(
                                'Аннотация на встречи:',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                '1. Вы один(одна) и хотите пригласить кого-то. Создавайте индивидуальную встречу, укажите в описании куда идёте, что будете делать.',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                '2. Вас, например, двое. Один создаёт коллективную встречу, и  пишет: ждём двух девушек, и что вы предлагаете. (К примеру, пьём кофе на набережной и т.п.)',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                '3. Вы - компания и хотите устроить что-то масштабное. Один пусть создаёт коллективную встречу, опишите кратко предложение.',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                '4. Когда кто-нибудь вступит, придет уведомление как создателю.',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: const Text(
                    'Как создать встречу',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: width * 0.03),
                  constraints: BoxConstraints(maxHeight: height * 0.04),
                  padding: EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: width * 0.011,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: width * 0.74,
                        child: Autocomplete<String>(
                          optionsMaxHeight:
                              MediaQuery.of(context).size.height * 0.2,
                          optionsViewBuilder: (context, onSelected, options) {
                            return cityDropdown(context, options, onSelected);
                          },
                          initialValue: TextEditingValue(text: meetCity),
                          optionsBuilder: (textEditingValue) {
                            if (textEditingValue.text == '') {
                              return [];
                            }
                            return cities
                                .where(
                                  (city) => city.toLowerCase().startsWith(
                                    textEditingValue.text.toLowerCase(),
                                  ),
                                )
                                .toList()
                              ..sort((a, b) => a.compareTo(b));
                          },
                          onSelected: (String val) {
                            setState(() {
                              city.text = val
                                  .split(RegExp(r'(?! )\s{2,}'))
                                  .join(' ')
                                  .split(RegExp(r'\s+$'))
                                  .join('');
                              meetCity = city.text;
                              meets = firebaseFirestore
                                  .collection('meets')
                                  .where(
                                    'city',
                                    isEqualTo: city.text
                                        .split(RegExp(r'(?! )\s{2,}'))
                                        .join(' ')
                                        .split(RegExp(r'\s+$'))
                                        .join(''),
                                  )
                                  .snapshots();
                            });
                          },
                          fieldViewBuilder:
                              (context, controller, focusNode, onSubmitted) {
                                return TextField(
                                  controller: controller,
                                  style: const TextStyle(color: Colors.white),
                                  focusNode: focusNode,
                                  decoration: const InputDecoration(
                                    alignLabelWithHint: false,
                                    border: InputBorder.none,
                                    hintText: 'Введите ваш город',
                                    hintStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                  ),
                                  onSubmitted: (String value) {
                                    onSubmitted();
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      city.text = value
                                          .split(RegExp(r'(?! )\s{2,}'))
                                          .join(' ')
                                          .split(RegExp(r'\s+$'))
                                          .join('');
                                      meetCity = city.text;
                                      meets = firebaseFirestore
                                          .collection('meets')
                                          .where(
                                            'city',
                                            isEqualTo: city.text
                                                .split(RegExp(r'(?! )\s{2,}'))
                                                .join(' ')
                                                .split(RegExp(r'\s+$'))
                                                .join(''),
                                          )
                                          .snapshots();
                                    });
                                  },
                                );
                              },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (city.text == '') {
                              meets = firebaseFirestore
                                  .collection('meets')
                                  .snapshots();
                            } else {
                              meets = firebaseFirestore
                                  .collection('meets')
                                  .where(
                                    'city',
                                    isEqualTo: city.text
                                        .split(RegExp(r'(?! )\s{2,}'))
                                        .join(' ')
                                        .split(RegExp(r'\s+$'))
                                        .join(''),
                                  )
                                  .snapshots();
                            }
                          });
                        },
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.search),
                        iconSize: 20,
                        splashRadius: 1,
                        splashColor: Colors.black,
                      ),
                    ],
                  ),
                ),
                StreamBuilder<Object>(
                  stream: meets,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      return snapshot.hasData
                          ? Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: snapshot.data.docs.length,
                                itemBuilder: (BuildContext context, index) {
                                  return kartovhkaGroupVstrechi(
                                    context,
                                    snapshot,
                                    index,
                                    firebaseFirestore.collection('meets'),
                                  );
                                },
                              ),
                            )
                          : const Center(child: Text('Встреч нет'));
                    } else {
                      return Container(
                        height: 30,
                        width: 30,
                        margin: const EdgeInsets.all(20),
                        child: const CircularProgressIndicator(
                          color: Colors.orangeAccent,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<int> GetUsers(String id) async {
    var kolvo_users2 = await firebaseFirestore
        .collection('users')
        .doc(id)
        .collection('users')
        .snapshots()
        .length;
    return kolvo_users2;
  }

  Widget kartovhkaGroupVstrechi(
    context,
    AsyncSnapshot snapshot,
    int index,
    CollectionReference meets,
  ) {
    return snapshot.hasData
        ? Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: const BorderRadius.all(Radius.circular(18)),
            ),
            child: InkWell(
              onTap: (() async {
                DocumentSnapshot doc = await firebaseFirestore
                    .collection('meets')
                    .doc(snapshot.data.docs[index].id)
                    .get();
                List users = doc.get('users');

                bool is_user_join = false;

                for (int i = 0; i < users.length; i++) {
                  if (users[i] == firebaseAuth.currentUser!.uid) {
                    is_user_join = true;
                  }
                }
                var doc12 = await firebaseFirestore
                    .collection('users')
                    .doc(snapshot.data.docs[index]['admin'])
                    .get();
                if (snapshot.data.docs[index]['type'] == 'групповая') {
                  nextScreen(
                    context,
                    AboutMeet(
                      id: snapshot.data.docs[index].id,
                      users: users,
                      name: snapshot.data.docs[index]['name'],
                      is_user_join: is_user_join,
                    ),
                  );
                } else {
                  nextScreen(
                    context,
                    AboutIndividualMeet(
                      snapshot: snapshot,
                      index: index,
                      doc: doc12,
                    ),
                  );
                }
              }),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  color: Colors.orangeAccent.shade700.withValues(alpha: 0.3),
                ),
                width: double.infinity,
                child: ListTile(
                  title: SizedBox(
                    height: 70,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            "${snapshot.data.docs[index]['city']}, ${snapshot.data.docs[index]['name']}",
                            overflow: TextOverflow.visible,
                            softWrap: true,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            snapshot.data.docs[index]['description'],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                snapshot.data.docs[index]['datetime'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              if (snapshot.data.docs[index]['admin'] ==
                                  firebaseAuth.currentUser!.uid)
                                const Text(
                                  'Вы владелец',
                                  style: TextStyle(color: Colors.greenAccent),
                                  softWrap: false,
                                ),
                              if (snapshot.data.docs[index]['admin'] !=
                                      firebaseAuth.currentUser!.uid &&
                                  snapshot.data.docs[index]['users'].contains(
                                    firebaseAuth.currentUser!.uid,
                                  ))
                                const Text(
                                  'Вы участник',
                                  style: TextStyle(color: Colors.yellow),
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  subtitle: snapshot.data.docs[index]['recentMessage'] == ''
                      ? const SizedBox(
                          child: Text(
                            'Нет сообщений',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : Row(
                          children: [
                            Text(
                              snapshot.data.docs[index]['recentMessageSender'] +
                                  ':',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                snapshot.data.docs[index]['recentMessage'],
                                style: const TextStyle(color: Colors.white70),
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          )
        : Container();
  }
}
