import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:secure_string/secure_string.dart';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'package:url_launcher/url_launcher.dart';

class ServerFunctions {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FirebaseUser> createUser(
      TextEditingController controller, int index, String uid) async {
    SecureString secureString = new SecureString();
    String pass = secureString.generate(length: 64);
    try {
      FirebaseUser newUser = await _auth.createUserWithEmailAndPassword(
          email: controller.text, password: pass);

      newUser = await _auth.signInWithEmailAndPassword(
          email: controller.text, password: pass);
      UserUpdateInfo uInfo = new UserUpdateInfo();
      uInfo.displayName = userInfo.family[index].name;
      DataSnapshot snapshot = await userInfo.userReference.once();
      await _auth.updateProfile(uInfo);
      if (newUser != null) {
        Map newFamily =
            createFamilyList(snapshot, userInfo.family[index].name, uid);
        await userInfo.userReference
            .child("/family/")
            .update({userInfo.family[index].name: controller.text});
        DatabaseReference temp =
            FirebaseDatabase.instance.reference().child("users/" + newUser.uid);
        temp.update({
          'email': controller.text,
          'badge': snapshot.value['badge'],
          'events': "",
          'family': newFamily,
          'favorites': 'false',
          'firstLogin': 'true',
          'guests': snapshot.value['guests'],
          'isHead': 'false',
          'isManager': 'false',
          'name': userInfo.family[index].name,
          'type': snapshot.value['type']
        });
      }
      return newUser;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Map createFamilyList(DataSnapshot s, String name, String uid) {
    Map familyMap = new Map();
    void checkFamily(key, value) {
      if (key != name) {
        familyMap[key] = uid;
      }
    }

    s.value['family'].forEach(checkFamily);
    familyMap[userInfo.user.displayName] = "v";
    return familyMap;
  }

  Future closeBeach(bool weatherClosure) async {
    var url = 'https://membershipme.ddns.net/node/beachstatus';
    var success = false;
    if (weatherClosure) {
      await http
          .post(url,
              body: {"userID": userInfo.user.uid, "status": "false"},
              encoding: Encoding.getByName("utf-8"))
          .then((response) {
        if (response.body.toString() == "Success") {
          success = true;
        }
      });
    } else {
      await http
          .post(url,
              body: {"userID": userInfo.user.uid, "status": "true"},
              encoding: Encoding.getByName("utf-8"))
          .then((response) {
        if (response.body.toString() == "Success") {
          success = true;
        }
      });
    }

    return success;
  }

  Future deleteUser(int index) async {
    var url = 'https://membershipme.ddns.net/node';
    var success = false;
    await http
        .post(url,
            body: {
              "remName": userInfo.family[index].name,
              "sendName": userInfo.user.displayName,
              "userID": userInfo.user.uid
            },
            encoding: Encoding.getByName("utf-8"))
        .then((response) {
      if (response.body.toString() == "Success") {
        userInfo.userReference
            .child("/family/")
            .update({userInfo.family[index].name: "nv"});
        success = true;
      }
    });
    return success;
  }

  Future resetPassword(String e) async {
    bool sent = true;
    var url = 'https://membershipme.ddns.net/node/emailCheck';
    await http
        .post(url, body: {"email": e}, encoding: Encoding.getByName("utf-8"))
        .then((response) async {
      if (response.body.toString() == "Reset") {
        sent = true;
        await _auth.sendPasswordResetEmail(email: e).catchError((e) {
          sent = false;
        });
      } else {
        sent = false;
      }
    });
    return sent;
  }

  launchURL(String event) async {
    String url = 'https://lake-parsippany.org/event-' + event;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
