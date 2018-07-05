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
  TextEditingController _controller2 = new TextEditingController();

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
                            if (uidSnapshot.value == null) {
                              showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext context) =>
                                      new AlertDialog(
                                        title:
                                            new Text("Badge Number Not Found"),
                                        content: new TextField(
                                          keyboardType: TextInputType.number,
                                          controller: _controller2,
                                          decoration: new InputDecoration(
                                            hintText: 'Number of People',
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        actions: <Widget>[
                                          new FlatButton(
                                              onPressed: () async {
                                                DatabaseReference errors =
                                                    FirebaseDatabase.instance
                                                        .reference()
                                                        .child("errors");
                                                errors.update({
                                                  _controller.text: "Not Found"
                                                });
                                                DatabaseReference
                                                    countReference =
                                                    FirebaseDatabase.instance
                                                        .reference()
                                                        .child("beachCheckIn/" +
                                                            new DateTime.now()
                                                                .year
                                                                .toString() +
                                                            "/" +
                                                            new DateTime.now()
                                                                .month
                                                                .toString() +
                                                            "/" +
                                                            new DateTime.now()
                                                                .day
                                                                .toString());
                                                DataSnapshot countSnapShot =
                                                    await countReference.once();
                                                int tempHour =
                                                    new DateTime.now().hour;
                                                int tempCount = 0;
                                                if (tempHour > 12) {
                                                  tempHour -= 12;
                                                }
                                                int secondHour = tempHour + 1;
                                                if (secondHour > 12) {
                                                  secondHour = 1;
                                                }
                                                try {
                                                  tempCount = countSnapShot
                                                      .value[tempHour
                                                          .toString() +
                                                      "-" +
                                                      secondHour.toString()];
                                                } catch (e) {
                                                  tempCount = 0;
                                                }
                                                if (tempCount == null) {
                                                  tempCount = 0;
                                                }
                                                tempCount += int
                                                    .parse(_controller2.text);
                                                await countReference.update({
                                                  tempHour.toString() +
                                                          "-" +
                                                          secondHour.toString():
                                                      tempCount
                                                });
                                                int tempRawCount = 0;
                                                try {
                                                  tempRawCount = (countSnapShot
                                                      .value['raw']);
                                                } catch (e) {
                                                  tempRawCount = 0;
                                                }
                                                if (tempRawCount == null) {
                                                  tempRawCount = 0;
                                                }
                                                tempRawCount += int
                                                    .parse(_controller2.text);
                                                await countReference.update(
                                                    {'raw': tempRawCount});
                                                DatabaseReference checkInReference = FirebaseDatabase.instance
                                                    .reference()
                                                    .child("beachCheckIn/" +
                                                    new DateTime.now().year.toString() +
                                                    "/" +
                                                    new DateTime.now().month.toString() +
                                                    "/" +
                                                    new DateTime.now().day.toString() +
                                                    "/" +
                                                    _controller.text.toString() +
                                                    "- UNKNOWN"
                                                    );
                                                checkInReference.update({_controller2.text: tempHour.toString() + ":" + new DateTime.now().minute.toString()});
                                                Navigator
                                                    .of(context,
                                                        rootNavigator: true)
                                                    .pushNamed("/screen6");
                                              },
                                              child: Text(
                                                "Continue",
                                                textAlign: TextAlign.center,
                                                style: new TextStyle(
                                                    fontSize: 15.0,
                                                    color: Colors.lightBlue),
                                              ))
                                        ],
                                      ));
                            } else {
                              Map badgeNumbers = uidSnapshot.value;

                              badgeNumbers.forEach((key, value) {
                                barcode = key;
                              });
                              scan(barcode);
                            }
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
  TextEditingController _controller = new TextEditingController();

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
          ?   Column(children: <Widget>[
            Row(children: <Widget>[
              Expanded(child:
              Container(padding: new EdgeInsets.only(left: 25.0), child: Text("Family Members Not Listed - "))),
    Expanded(child: Container(padding: new EdgeInsets.only(right: 55.0, left: 55.0),width: 50.0, child: TextField(
    keyboardType: TextInputType.number,
    controller: _controller,
      decoration: new InputDecoration(
        hintText: 'Extras',
      ),
    style: new TextStyle(
    fontSize: 25.0, color: Colors.black),
    textAlign: TextAlign.center,
    ))),],),
              new Container(
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
                  int tempHour =
                      new DateTime.now().hour;
                  int tempCount = 0;
                  if (tempHour > 12) {
                    tempHour -= 12;
                  }
                  int secondHour = tempHour + 1;
                  if (secondHour > 12) {
                    secondHour = 1;
                  }
                  try {
                    tempCount = countSnapShot
                        .value[tempHour
                        .toString() +
                        "-" +
                        secondHour.toString()];
                  } catch (e) {
                    tempCount = 0;
                  }
                  if (tempCount == null) {
                    tempCount = 0;
                  }
                  tempCount += count;
                  int extras = 0;
                  try{
                    extras = int.parse(_controller.text);
                  }
                  catch (e)
                  {
                    extras = 0;
                  }
                  tempCount += extras;

                  await countReference.update({
                    tempHour.toString() +
                        "-" +
                        secondHour.toString():
                    tempCount
                  });
                  int tempRawCount = 0;
                  try {
                    tempRawCount = (countSnapShot.value['raw']);
                  } catch (e) {
                    tempRawCount = 0;
                  }
                  if (tempRawCount == null) {
                    tempRawCount = 0;
                  }
                  tempRawCount += count;
                  tempRawCount += extras;
                  if(extras > 0)
                    {
                      DatabaseReference errorReference = FirebaseDatabase.instance
                          .reference().child("errors");
                      await errorReference.update({badgeNumber.value.toString(): "Family Members"});
                    }
                  await countReference.update({'raw': tempRawCount});

                  Navigator
                      .of(context, rootNavigator: true)
                      .pushNamed("/screen6");
                },
                child: new Text("Check In"),
                color: Colors.lightBlue,
              ))],)
          : new Container(height: 0.0)
    ]);
  }
}
