import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'family.dart';
import 'main.dart';

class AppUserInfo {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DatabaseReference mainReference;
  DatabaseReference userReference;
  DataSnapshot userSnapshot;
  DataSnapshot snapshot;
  bool isHead;
  bool isManager;
  bool favorites;
  int badgeNumber;
  List<Family> family = new List<Family>();
  Map familyList;
  ImageProvider imageProvider;
  FirebaseUser user;
  List<int> saved = new List();
  bool isBeach = false;
  bool signedIn = false;


  Future handleSignInMain() async {
    final storage = new FlutterSecureStorage();
    String uName = await storage.read(key: "username");
    String pass = await storage.read(key: "password");
    user = await _auth.signInWithEmailAndPassword(email: uName, password: pass);
    if (uName != "beachmanager@lake-parsippany.org") {
      getVars();
    } else {
      /*SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight
      ]);*/
      isBeach = true;
      isManager = false;
    }
  }

  Future<FirebaseUser> handleSignIn(String u, String p) async {


    try {
      List<String> uName = u.split(" ");
      user = await _auth.signInWithEmailAndPassword(
        email: uName[0],
        password: p,
      );
    if (user != null && user.email != "beachmanager@lake-parsippany.org") {
      await setFirstRun();
      await storeInfo(uName[0], p);
      try {
        mainReference =
            FirebaseDatabase.instance.reference().child("users/" + user.uid);
        mainReference.update({"email": uName[0]});
        snapshot = await mainReference.once();
        if (snapshot.value['firstLogin'] == "true") {
          mainReference.update({'firstLogin': "false"});
          var url = 'https://membershipme.ddns.net/node/emailVerified';
          await http
              .post(url,
              body: {
                "email": uName[0],
              },
              encoding: Encoding.getByName("utf-8"))
              .then((response) async {
            if (response.body.toString() != "Done") {
              return false;
            }
          });
        }
        Map family = snapshot.value['family'];
        family.forEach(updateVerified);
        getVars();
      } catch (e) {}
    }else if (user != null && user.email == "beachmanager@lake-parsippany.org"){
      isBeach = true;
      isManager = false;
      await setFirstRun();
      await storeInfo(uName[0], p);
    }
    } catch (e) {
    }

    return user;
  }

  void getVars() async{
    userReference =
        FirebaseDatabase.instance.reference().child("users/" + user.uid);
    userSnapshot = await userReference.once();
    family.clear();
    familyList = userSnapshot.value['family'];
    isHead = userSnapshot.value['isHead'];
    isManager = userSnapshot.value['isManager'];
    favorites = userSnapshot.value['favorites'] == "true";
    badgeNumber = userSnapshot.value['badge'];

    try {
      imageProvider = new NetworkImage(user.photoUrl);
    } catch (e) {
      imageProvider = new AssetImage("assets/png/nouser.png");
    }
    if (familyList != null) {
      familyList.forEach(createFamily);
    }
    String events = userSnapshot.value['events'];
    List<String> temp = events.split("/");
    for (final i in temp) {
      if (i != "") {
        saved.add(int.parse(i));
      }
    }
    signedIn = true;
  }

  void updateVerified(key, value) {
    try {
      mainReference = FirebaseDatabase.instance.reference().child("users/" + key);
      mainReference.child("/family/").update({user.displayName: "v"});
    } catch (e) {}
  }

  void createFamily(key, value) {
    family.add(new Family(key, value));
  }


  setFirstRun() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('firstRun', false);
  }

  storeInfo(String u, String p) async {
    final storage = new FlutterSecureStorage();
    String user = u;
    String pass = p;
    storage.write(key: "username", value: user);
    storage.write(key: "password", value: pass);
  }

  toggleFavorite(bool f) {
    mainReference =
        FirebaseDatabase.instance.reference().child("users/" + userInfo.user.uid);
    mainReference.update({"favorites": f.toString()});
  }

  signOut() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('firstRun', true);

    final storage = new FlutterSecureStorage();
    storage.delete(key: "username");
    storage.delete(key: "password");

    await _auth.signOut();

    mainReference = null;
    userReference = null;
    userSnapshot = null;
    snapshot = null;
    isHead = false;
    isManager = false;
    favorites = false;
    badgeNumber = 0;
    family = new List<Family>();
    familyList = null;
    imageProvider = null;
    user = null;
    saved = new List();
    isBeach = false;
    signedIn = false;
  }

}


