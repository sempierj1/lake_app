import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'menuCamera.dart';

class QrScanner extends StatefulWidget {
  QrScanner({Key key, this.title, this.uid}) : super(key: key);

  final String title;
  final String uid;

  final Map<String, dynamic> pluginParameters = {};

  @override
  _QrScanner createState() => new _QrScanner(uid);
}

class _QrScanner extends State<QrScanner> {
  String barcode = "";
  bool scanned = false;
  final String uid;
  Map<String, bool> values = new Map();

  _QrScanner(this.uid);

  @override
  initState() {
    super.initState();
    scan();
  }

  List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: new Text('QR Scanner'),
          ),
          body: new Center(
            child: new ListView(
              children: children ?? <Widget>[new Container(height: 0.0)],
            ),
          )),
    );
  }

  Future scan() async {
    String barcode;
    if (uid == null) {
      barcode = await BarcodeScanner.scan();
    } else {
      barcode = uid;
    }
    DatabaseReference mainReference =
        FirebaseDatabase.instance.reference().child("users/" + barcode);
    DataSnapshot snapshot = await mainReference.once();
    String type = snapshot.value['type'].toString();
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

  final String title;
  final Map values;
  final int index;
  final List family;
  final String barcode;
  final String type;

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
              padding: new EdgeInsets.only(top: 45.0),
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
