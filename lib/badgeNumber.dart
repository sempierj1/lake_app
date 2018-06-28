import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'menuCamera.dart';

/*Handles checkins with badgenumber. Takes in a badge number and will provide a list of all
family members associated with that badge, allowing for the user to check in.
 */

class BadgeNumber extends StatefulWidget {
  BadgeNumber({Key key, this.title, this.uid}) : super(key: key);

  final String title;
  final String uid;

  final Map<String, dynamic> pluginParameters = {};

  @override
  _BadgeNumber createState() => new _BadgeNumber(uid);
}

//Checks if a uid has been provided, if not, user will be prompted for one before continuing.
//Once a uid has been provided it will load the family members associated with that badge.

class _BadgeNumber extends State<BadgeNumber> {
  String barcode = "";
  bool scanned = false;
  final String uid;
  Map<String, bool> values = new Map();

  _BadgeNumber(this.uid);

  @override
  initState() {
    super.initState();
    if (uid != null) {
      scan(uid);
    }
  }

  List<Widget> children;
  TextEditingController _controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool first = children != null ? false : true;
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: new Text('Check-In'),
          ),
          body: new Center(
            child: first
                ? new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Container(
                          width: 155.0,
                          child: new TextField(
                            keyboardType: TextInputType.number,
                            controller: _controller,
                            style: new TextStyle(
                                fontSize: 55.0, color: Colors.black),
                            textAlign: TextAlign.center,
                          )),
                      new FlatButton(
                          onPressed: () async {
                            DatabaseReference badgeReference = FirebaseDatabase
                                .instance
                                .reference()
                                .child("badges/" + _controller.text);
                            DataSnapshot uidSnapshot =
                                await badgeReference.once();
                            Map badgeNumbers = uidSnapshot.value;

                            badgeNumbers.forEach((key, value) {
                              barcode = key;
                            });
                            scan(barcode);
                          },
                          child: new Text(
                            "Continue",
                            style: new TextStyle(
                                fontSize: 45.0, color: Colors.lightBlue),
                          ))
                    ],
                  )
                : new ListView(children: children),
          )),
    );
  }

  //Grabs all family associated with a given uid (found via badge number) and creates a list of them.
  //The list is passed to the next function and the list is displayed with check boxes to allow for check in

  Future scan(String s) async {
    String barcode = s;

    DatabaseReference mainReference =
        FirebaseDatabase.instance.reference().child("users/" + barcode);
    DataSnapshot snapshot = await mainReference.once();
    String type = snapshot.value['type'];
    DatabaseReference guestReference = FirebaseDatabase.instance
        .reference()
        .child("users/" + barcode + "/guest");
    DataSnapshot guests = await guestReference.once();
    Map family = snapshot.value['family'];
    List familyList = new List();
    if (family != null) {
      family[snapshot.value['name']] = "";
      family.forEach((key, value) {
        familyList.add(key.toString());
      });
      familyList.sort();

      for (int i = 0; i < guests.value; i++) {
        familyList.add("Guest " + (i + 1).toString());
      }
      for (final i in familyList) {
        values[i] = false;
      }
    } else {
      familyList.add(snapshot.value['name']);
      for (final i in familyList) {
        values[i] = false;
      }
    }

    setState(() {
      this.children = new List.generate(
          familyList.length,
          (int i) => new CheckInWidget(
              values: values,
              index: i,
              family: familyList,
              barcode: barcode,
              type: type));
    });

    /*this.children = new List.generate(
            family.length, (int i) => new CheckInWidget(i, context, family));*/
  }
}

class CheckInWidget extends StatefulWidget {
  CheckInWidget(
      {Key key,
      this.title,
      this.values,
      this.index,
      this.family,
      this.barcode,
      this.type})
      : super(key: key);

  final String type;
  final String title;
  final Map values;
  final int index;
  final List family;
  final String barcode;

  @override
  _CheckInWidget createState() =>
      new _CheckInWidget(index, family, barcode, values, type);
}

class _CheckInWidget extends State<CheckInWidget> {
  final int index;
  final List family;
  final String barcode;
  final Map values;
  final String type;

  _CheckInWidget(this.index, this.family, this.barcode, this.values, this.type);

  @override
  Widget build(BuildContext context) {
    StorageReference ref;
    bool isPic = true;
    bool isGuest = family[index].toString().contains("Guest");
    try {
      ref = FirebaseStorage.instance.ref().child(family[index] + ".png");
    } catch (e) {
      isPic = false;
    }
    return new Column(children: <Widget>[
      new Row(children: <Widget>[
        new Expanded(
          child: new Container(
            padding: new EdgeInsets.only(left: 25.0, top: 25.0),
            child: new Align(
                alignment: Alignment.centerLeft,
                child: new Text(family[index],
                    style:
                        new TextStyle(fontFamily: 'Roboto', fontSize: 20.0))),
          ),
        ),
        new Expanded(
            child: isGuest
                ? new Container(width: 50.0)
                : isPic
                    ? new FutureBuilder(
                        future: ref.getDownloadURL(),
                        builder: (BuildContext context, AsyncSnapshot url) {
                          if (url.hasData) {
                            if (url.data != null) {
                              return new Container(
                                  padding: new EdgeInsets.only(top: 25.0),
                                  child: new Center(
                                      child: new GestureDetector(
                                          onTap: () {
                                            List<String> tempList = new List();
                                            tempList.add(family[index]);
                                            tempList.add(barcode);
                                            Navigator.push(
                                                context,
                                                new MaterialPageRoute(
                                                    builder: (context) =>
                                                        new CameraState(
                                                            list: tempList)));
                                          },
                                          child: new CircleAvatar(
                                            backgroundImage:
                                                new NetworkImage(url.data),
                                            radius: 50.0,
                                          ))));
                            }
                          } else {
                            /*
                            return Container(
                                padding: new EdgeInsets.only(top: 25.0),
                                child: new Center(
                                    child: new IconButton(
                                        icon: new Icon(Icons.add_a_photo),
                                        iconSize: 50.0,
                                        onPressed: () async {
                                          List<String> tempList = new List();
                                          tempList.add(family[index]);
                                          tempList.add(barcode);
                                          Navigator.push(
                                              context,
                                              new MaterialPageRoute(
                                                  builder: (context) =>
                                                      new CameraState(
                                                          list: tempList)));
                                        })));
                                        */
                            return Container(width: 1.0, height: 1.0);
                          }
                        })
                    : new Container(height: 0.0)),
        new Expanded(
            child: new Container(
                padding: new EdgeInsets.only(right: 25.0, top: 25.0),
                child: new Align(
                    alignment: Alignment.centerRight,
                    child: new Checkbox(
                        value: values[family[index]],
                        onChanged: (bool newValue) {
                          setState(() {
                            values[family[index]] = newValue;
                          });
                        })))),
      ]),
      index == family.length - 1
          ? new Container(
              padding: new EdgeInsets.only(top: 45.0, bottom: 20.0),
              child: new RaisedButton(
                onPressed: () async {
                  DatabaseReference badgeReference = FirebaseDatabase.instance
                      .reference()
                      .child("users/" + barcode + "/badge");
                  DataSnapshot badgeNumber = await badgeReference.once();
                  DatabaseReference checkInReference = FirebaseDatabase.instance
                      .reference()
                      .child("beachCheckIn/" +
                          new DateTime.now().year.toString() +
                          "/" +
                          new DateTime.now().month.toString() +
                          "/" +
                          new DateTime.now().day.toString() +
                          "/" +
                          badgeNumber.value.toString() +
                          "-" +
                          type.toString());
                  int count = 0;
                  for (final i in family) {
                    if (values[i] == true) {
                      count++;
                      await checkInReference.update({
                        i: new DateTime.now().hour.toString() +
                            ":" +
                            new DateTime.now().minute.toString()
                      });
                    }
                  }
                  DatabaseReference countReference = FirebaseDatabase.instance
                      .reference()
                      .child("beachCheckIn/" +
                      new DateTime.now().year.toString() +
                      "/" +
                      new DateTime.now().month.toString() +
                      "/" +
                      new DateTime.now().day.toString());
                  DataSnapshot countSnapShot = await countReference.once();
                  print(new DateTime.now().hour);
                  switch (new DateTime.now().hour) {
                    case 10:
                      {
                        int tempVal = 0;
                        try {
                          tempVal =
                          (countSnapShot.value['10-11']);
                        }
                        catch (e)
                        {
                          tempVal = 0;
                        }
                        if(tempVal == null)
                        {
                          tempVal = 0;
                        }
                        tempVal += count;
                        await countReference.update({'10-11': tempVal});
                        break;
                      }
                    case 11:
                      {
                        int tempVal = 0;
                        try {
                          tempVal =
                          (countSnapShot.value['11-12']);
                        }
                        catch (e)
                        {
                          tempVal = 0;
                        }
                        if(tempVal == null)
                        {
                          tempVal = 0;
                        }
                        tempVal += count;
                        await countReference.update({'11-12': tempVal});
                        break;
                      }
                    case 12:
                      {
                        int tempVal = 0;
                        try {
                          tempVal =
                          (countSnapShot.value['12-1']);
                        }
                        catch (e)
                        {
                          tempVal = 0;
                        }
                        if(tempVal == null)
                        {
                          tempVal = 0;
                        }
                        tempVal += count;
                        await countReference.update({'12-1': tempVal});
                        break;
                      }
                    case 13:
                      {
                        int tempVal = 0;
                        try {
                          tempVal =
                          (countSnapShot.value['1-2']);
                        }
                        catch (e)
                        {
                          tempVal = 0;
                        }
                        if(tempVal == null)
                        {
                          tempVal = 0;
                        }
                        tempVal += count;
                        await countReference.update({'1-2': tempVal});
                        break;
                      }
                    case 14:
                      {
                        int tempVal = 0;
                        try {
                          tempVal =
                          (countSnapShot.value['2-3']);
                        }
                        catch (e)
                        {
                          tempVal = 0;
                        }
                        if(tempVal == null)
                        {
                          tempVal = 0;
                        }
                        tempVal += count;
                        await countReference.update({'2-3': tempVal});
                        break;
                      }
                    case 15:
                      {
                        int tempVal = 0;
                        try {
                          tempVal =
                          (countSnapShot.value['3-4']);
                        }
                        catch (e)
                        {
                          tempVal = 0;
                        }
                        if(tempVal == null)
                        {
                          tempVal = 0;
                        }
                        tempVal += count;
                        await countReference.update({'3-4': tempVal});
                        break;
                      }
                    case 16:
                      {
                        int tempVal = 0;
                        try {
                          tempVal =
                          (countSnapShot.value['4-5']);
                        }
                        catch (e)
                        {
                          tempVal = 0;
                        }
                        if(tempVal == null)
                        {
                          tempVal = 0;
                        }
                        tempVal += count;
                        await countReference.update({'4-5': tempVal});
                        break;
                      }
                    case 17:
                      {
                        int tempVal = 0;
                        try {
                          tempVal =
                          (countSnapShot.value['5-6']);
                        }
                        catch (e)
                        {
                          tempVal = 0;
                        }
                        if(tempVal == null)
                        {
                          tempVal = 0;
                        }
                        tempVal += count;
                        await countReference.update({'5-6': tempVal});
                        break;
                      }
                    case 18:
                      {
                        int tempVal = 0;
                        try {
                          tempVal =
                          (countSnapShot.value['6-7']);
                        }
                        catch (e)
                        {
                          tempVal = 0;
                        }
                        if(tempVal == null)
                        {
                          tempVal = 0;
                        }
                        tempVal += count;
                        await countReference.update({'6-7': tempVal});
                        break;
                      }
                    default:{}
                  }
                  int tempRawCount = 0;
                  try {
                    tempRawCount = (countSnapShot.value['raw']);
                  }
                  catch (e)
                  {
                    tempRawCount = 0;
                  }
                  if(tempRawCount == null)
                  {
                    tempRawCount = 0;
                  }
                  tempRawCount += count;
                  await countReference.update({'raw': tempRawCount});

                  Navigator
                      .of(context, rootNavigator: true)
                      .pushNamed("/screen6");
                },
                child: new Text("Check In"),
                color: Colors.lightBlue,
              ))
          : new Container(height: 0.0)
    ]);
  }
}
