import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wbrs/app/helper/global.dart';
import 'package:wbrs/app/widgets/circle_user_image.dart';

class HelperFunctions {
  //keys
  static String userIdKey = 'USERKEY';
  static String photoUrl = 'PHOTOURL';
  static String userLoggedInKey = 'LOGGEDINKEY';
  static String userNameKey = 'USERNAMEKEY';
  static String userEmailKey = 'USEREMAILKEY';
  static String displayNameKey = 'USERDISPLAYNAMEKEY';
  static String userProfilePicKey = 'USERPROFILEPICKEY';

  // saving the data to SF

  static Future<bool> saveUserLoggedInStatus(bool isUserLoggedIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setBool(userLoggedInKey, isUserLoggedIn);
  }

  static Future<bool> saveUserNameSF(String userName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userNameKey, userName);
  }

  static Future<bool> saveUserEmailSF(String userEmail) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userEmailKey, userEmail);
  }

  // getting the data from SF

  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoggedInKey);
  }

  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  Future<String?> getDisplayName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(displayNameKey);
  }

  Future<String?> getUserProfileUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userProfilePicKey);
  }
}

getUserGroup() async {
  var doc = await firebaseFirestore
      .collection('users')
      .doc(firebaseAuth.currentUser!.uid)
      .get();

  return doc.get('группа');
}

userImageWithCircle(userPhotoUrl, group, online, [width, height]) {
  if (width != null) {
    return UserImage(
      userPhotoUrl: userPhotoUrl,
      group: group,
      width: width,
      height: height,
      online: online,
    );
  } else {
    return UserImage(userPhotoUrl: userPhotoUrl, group: group, online: online);
  }
}

List<Widget> getLikeGroup(myGroup) {
  List spisok = [];
  if (myGroup == 'коричнево-красная' ||
      myGroup == 'коричнево-синяя' ||
      myGroup == 'коричнево-белая' ||
      myGroup == 'коричневая') {
    spisok = ['Все белые', 'Все коричневые', 'Сине-белая'];
  } else if (myGroup == 'красно-белая' || myGroup == 'красно-синяя') {
    spisok = ['Чистая синяя', 'Сине-коричневая'];
  } else if (myGroup == 'красная') {
    spisok = ['Чистая синяя', 'Сине-коричневая'];
  } else if (myGroup == 'красно-коричневая') {
    spisok = ['Все белые', 'Коричнево-белая', 'Сине-белая'];
  } else if (myGroup == 'коричнево-белая') {
    spisok = ['Все белые', 'Сине-белая', 'Все коричневые', 'Красно-коричневая'];
  } else if (myGroup == 'синяя' || myGroup == 'сине-коричневая') {
    spisok = ['Чисто красная', 'Красно-белая', 'Сине-красная', 'Красно-синяя'];
  } else if (myGroup == 'сине-белая') {
    spisok = ['Все коричневые', 'Все белые', 'Красно-коричневая'];
  } else if (myGroup == 'сине-красная') {
    spisok = ['Чисто синяя', 'Сине-коричневая'];
  } else if (myGroup == 'бело-красная' ||
      myGroup == 'бело-синяя' ||
      myGroup == 'бело-коричневая' ||
      myGroup == 'белая') {
    spisok = ['Все коричневые', 'Сине-белая', 'Красно-коричневая'];
  }

  List<Widget> spisokOfWidgets = [];

  for (int i = 0; i < spisok.length; i++) {
    spisokOfWidgets.add(
      Text(
        spisok[i],
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
  if (spisok.isNotEmpty) {
    return spisokOfWidgets;
  } else {
    return [
      Text(myGroup, style: const TextStyle(color: Colors.white, fontSize: 14)),
    ];
  }
}

cityDropdown(context, options, onSelected) {
  return Align(
    alignment: Alignment.topCenter,
    child: Material(
      surfaceTintColor: Colors.white54,
      type: MaterialType.transparency,
      elevation: 4.0,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.3,
        ),
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: options.length,
          itemExtent: 50,
          itemBuilder: (context, index) {
            final option = options.elementAt(index);
            return ListTile(
              tileColor: grey,
              title: Text(
                option.trim(),
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () => onSelected(option),
            );
          },
        ),
      ),
    ),
  );
}

statusRow(bool online, DateTime lastOnlineTs, String pol) {
  int diff = lastOnlineTs.difference(DateTime.now()).inMinutes.abs();
  String compareDate = diff > 60
      ? diff / 60 > 24
            ? diff / 60 / 24 > 7
                  ? 'больше недели'
                  : '${(diff / 60 / 24).round()} дней'
            : '${(diff / 60).round()} часов'
      : '$diff минут';
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        online
            ? 'В сети'
            : '${pol.toLowerCase() == 'м' ? "Был" : "Была"} в сети $compareDate назад',
        style: TextStyle(
          color: online ? Colors.green : Colors.grey,
          fontSize: 14,
        ),
      ),
    ],
  );
}
