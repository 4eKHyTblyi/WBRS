// ignore_for_file: camel_case_types

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wbrs/app/pages/policy/confidecialnost.dart';
import 'package:wbrs/app/pages/policy/offer.dart';
import 'package:wbrs/app/pages/policy/rules.dart';
import 'package:wbrs/app/pages/policy/soglashenie.dart';
import 'package:wbrs/app/widgets/drawer.dart';
import 'package:wbrs/app/widgets/widgets.dart';

class About_App extends StatelessWidget {
  const About_App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [
          Image.asset(
            'assets/fon.jpg',
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            scale: 0.6,
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 22,
              ),
              title: const Text('О приложении'),
              backgroundColor: Colors.transparent,
            ),
            drawer: const MyDrawer(),
            body: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      nextScreen(context, const Politica());
                    },
                    style: const ButtonStyle(
                      padding: WidgetStatePropertyAll(EdgeInsets.all(10)),
                      backgroundColor: WidgetStatePropertyAll(
                        Colors.transparent,
                      ),
                    ),
                    child: const Text(
                      'Политика в отношении обработки персональных данных',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const Divider(height: 2, color: Colors.white, thickness: 1),
                  ElevatedButton(
                    onPressed: () {
                      nextScreen(context, const Rules());
                    },
                    style: const ButtonStyle(
                      padding: WidgetStatePropertyAll(EdgeInsets.all(10)),
                      backgroundColor: WidgetStatePropertyAll(
                        Colors.transparent,
                      ),
                    ),
                    child: const Text(
                      'Пользовательское соглашение',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const Divider(height: 2, color: Colors.white, thickness: 1),
                  ElevatedButton(
                    onPressed: () {
                      nextScreen(context, const Offer());
                    },
                    style: const ButtonStyle(
                      padding: WidgetStatePropertyAll(EdgeInsets.all(10)),
                      backgroundColor: WidgetStatePropertyAll(
                        Colors.transparent,
                      ),
                    ),
                    child: const Text(
                      'Публичная оферта',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const Divider(height: 2, color: Colors.white, thickness: 1),
                  ElevatedButton(
                    onPressed: () {
                      nextScreen(context, const Rule());
                    },
                    style: const ButtonStyle(
                      padding: WidgetStatePropertyAll(EdgeInsets.all(10)),
                      backgroundColor: WidgetStatePropertyAll(
                        Colors.transparent,
                      ),
                    ),
                    child: const Text(
                      'Правила использования приложения',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const Divider(height: 2, color: Colors.white, thickness: 1),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Версия приложения',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        Text(
                          '1.0.4',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 2),
                  GestureDetector(
                    onTap: () {
                      //nextScreenReplace(context, const ComplaintForm());
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: const Text(
                        'Обратная связь',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      print('migration started');
                      List<QueryDocumentSnapshot<Map<String, dynamic>>> items =
                          [];
                      await FirebaseFirestore.instance
                          .collection('chats')
                          .get()
                          .then((value) {
                            items = value.docs;
                          });
                      for (var i = 0; i < items.length; i++) {
                        QueryDocumentSnapshot<Map<String, dynamic>> element =
                            items[i];
                        try {
                          var elementData = element.data();

                          // Создаем копию данных для преобразования
                          Map<String, dynamic> dataToSend =
                              Map<String, dynamic>.from(elementData);

                          // Преобразуем Timestamp в строку или число
                          if (dataToSend['lastMessageSendTs'] != null) {
                            // Вариант 1: Преобразовать в строку
                            dataToSend['lastMessageSendTs'] =
                                dataToSend['lastMessageSendTs']
                                    .toDate()
                                    .toIso8601String();

                            // Или вариант 2: Преобразовать в миллисекунды
                            // dataToSend['lastOnlineTS'] = dataToSend['lastOnlineTS'].millisecondsSinceEpoch;
                          }
                          print(dataToSend);
                          var resp = await http.post(
                            Uri.parse('http://127.0.0.1:5005/chat'),
                            headers: {
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: jsonEncode({
                              'uid': element.id,
                              'resource': jsonEncode(dataToSend),
                            }),
                          );
                          print('Status: ${resp.statusCode}');
                          print('Response: ${resp.body}');
                        } catch (e) {
                          print(e);
                        }
                      }
                      // var settings = new ConnectionSettings(
                      //   host: '92.53.119.92',
                      //   port: 3306,
                      //   user: 'gen_user',
                      //   password: 'F3})V_2IGS_hfj',
                      //   db: 'default_db',
                      // );
                      // var conn = await MySqlConnection.connect(settings);
                      // print(conn.query('select * from users'));
                    },
                    child: Text("CLICK"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
