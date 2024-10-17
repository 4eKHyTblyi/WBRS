import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wbrs/helper/global.dart';

class HelperFunctions {
  //keys
  static String userIdKey = "USERKEY";
  static String photoUrl = "PHOTOURL";
  static String userLoggedInKey = "LOGGEDINKEY";
  static String userNameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";
  static String displayNameKey = "USERDISPLAYNAMEKEY";
  static String userProfilePicKey = "USERPROFILEPICKEY";

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

  static Future<String?> getUserEmailFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userEmailKey);
  }

  static Future<String?> getUserNameFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userNameKey);
  }

  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
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

Route createRoute(Widget Function() createPage) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => createPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

getUserGroup() async {
  var doc = await firebaseFirestore
      .collection('users')
      .doc(firebaseAuth.currentUser!.uid)
      .get();

  return doc.get('группа');
}

userImageWithCircle(userPhotoUrl, group, [width, height]) {
  return Container(
    width: width ?? 100,
    height: height ?? 100,
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(
        image: DecorationImage(
      image: AssetImage(getUserGroupCircle(group)),
      fit: BoxFit.cover,
    )),
    child: userPhotoUrl != ''
        ? CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
              userPhotoUrl,
              errorListener: (p0) {},
            ),
          )
        : const CircleAvatar(
            radius: 39,
            backgroundImage: AssetImage("assets/profile.png"),
          ),
  );
}

String getUserGroupCircle(group) {
  switch (group) {
    case "коричнево-красная":
      return "assets/circles/корк.png";
    case "красно-коричневая":
      return "assets/circles/ккор.png";
    case "красно-синяя":
      return "assets/circles/кс.png";
    case "коричнево-синяя":
      return "assets/circles/корс.png";
    case "коричнево-белая":
      return "assets/circles/корб.png";
    case "красно-белая":
      return "assets/circles/кб.png";
    case "сине-коричневая":
      return "assets/circles/скор.png";
    case "сине-красная":
      return "assets/circles/ск.png";
    case "сине-белая":
      return "assets/circles/сб.png";
    case "бело-коричневая":
      return "assets/circles/бкор.png";
    case "бело-красная":
      return "assets/circles/бк.png";
    case "бело-синяя":
      return "assets/circles/бс.png";
    case "белая":
      return "assets/circles/б.png";
    case "коричневая":
      return "assets/circles/кор.png";
    case "красная":
      return "assets/circles/к.png";
    case "синяя":
      return "assets/circles/с.png";

    default:
      return "assets/circles/с.png";
  }
}

List<Widget> getLikeGroup(myGroup) {
  List spisok = [];
  if (myGroup == "коричнево-красная" ||
      myGroup == "коричнево-синяя" ||
      myGroup == "коричнево-белая" ||
      myGroup == "коричневая") {
    spisok = ["Все белые", "Все коричневые", "Сине-белая"];
  } else if (myGroup == "красно-белая" || myGroup == "красно-синяя") {
    spisok = [
      "Чистая синяя",
      "Сине-коричневая",
    ];
  } else if (myGroup == "красная") {
    spisok = [
      "Чистая синяя",
      "Сине-коричневая",
    ];
  } else if (myGroup == "красно-коричневая") {
    spisok = [
      "Все белые",
      "Коричнево-белая",
      "Сине-белая",
    ];
  } else if (myGroup == "коричнево-белая") {
    spisok = [
      "Все белые",
      "Сине-белая",
      "Все коричневые",
      "Красно-коричневая",
    ];
  } else if (myGroup == "синяя" || myGroup == "сине-коричневая") {
    spisok = ["Чисто красная", "Красно-белая", "Сине-красная", "Красно-синяя"];
  } else if (myGroup == "сине-белая") {
    spisok = [
      "Все коричневые",
      "Все белые",
      "Красно-коричневая",
    ];
  } else if (myGroup == "сине-красная") {
    spisok = [
      "Чисто синяя",
      "Сине-коричневая",
    ];
  } else if (myGroup == "бело-красная" ||
      myGroup == "бело-синяя" ||
      myGroup == "бело-коричневая" ||
      myGroup == "белая") {
    spisok = [
      "Все коричневые",
      "Сине-белая",
      "Красно-коричневая",
    ];
  }

  List<Widget> spisokOfWidgets = [];

  for (int i = 0; i < spisok.length; i++) {
    spisokOfWidgets.add(Text(
      spisok[i],
      style: const TextStyle(color: Colors.white, fontSize: 14),
    ));
  }
  if (spisok.isNotEmpty) {
    return spisokOfWidgets;
  } else {
    return [
      Text(
        myGroup,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      )
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
            itemBuilder: (context, index) {
              final option = options.elementAt(index);
              return ListTile(
                tileColor: Colors.grey.shade700.withOpacity(0.8),
                title: Text(
                  option.trim(),
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () => onSelected(option),
              );
            }),
      ),
    ),
  );
}
