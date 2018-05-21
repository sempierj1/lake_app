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
              children: children ??
                  <Widget>[
                    new Container(height: 0.0)
                            ],
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
    DatabaseReference guestReference = FirebaseDatabase.instance.reference().child("users/" + barcode + "/guest");
    DataSnapshot guests = await guestReference.once();

    Map family = snapshot.value['family'];
    List familyList = new List();
    if (family != null){
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
    }
    else
    {
      familyList.add(snapshot.value['name']);
      for (final i in familyList) {
        values[i] = false;
      }
    }
    setState(() {
      this.children = new List.generate(
          familyList.length,
          (int i) => new CheckInWidget(
              values: values, index: i, family: familyList, barcode: barcode));
    });

    /*this.children = new List.generate(
            family.length, (int i) => new CheckInWidget(i, context, family));*/
  }
}

class CheckInWidget extends StatefulWidget {
  CheckInWidget(
      {Key key, this.title, this.values, this.index, this.family, this.barcode})
      : super(key: key);

  final String title;
  final Map values;
  final int index;
  final List family;
  final String barcode;

  @override
  _CheckInWidget createState() =>
      new _CheckInWidget(index, family, barcode, values);
}

class _CheckInWidget extends State<CheckInWidget> {
  final int index;
  final List family;
  final String barcode;
  final Map values;

  _CheckInWidget(this.index, this.family, this.barcode, this.values);

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
                  style: new TextStyle(fontFamily: 'Roboto', fontSize: 20.0))),
        ),
      ),
      new Expanded(
          child: isGuest ? new Container(width: 50.0) : isPic
              ? new FutureBuilder(
                  future: ref.getDownloadURL(),
                  builder: (BuildContext context, AsyncSnapshot url) {
                    if (url.hasData) {
                      if (url.data != null) {
                        return new Container(
                            padding: new EdgeInsets.only(top: 25.0),
                            child: new Center(
                                child: new GestureDetector(onTap: (){
                                  List<String> tempList = new List();
                                  tempList.add(family[index]);
                                  tempList.add(barcode);
                                  Navigator.push(
                                      context,
                                      new MaterialPageRoute(
                                          builder: (context) =>
                                          new CameraState(
                                              list: tempList)));
                                }, child: new CircleAvatar(
                              backgroundImage: new NetworkImage(url.data),
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
      new Expanded(child: new Container(
    padding: new EdgeInsets.only(right: 25.0, top: 25.0),
    child: new Align(
    alignment: Alignment.centerRight, child: new Checkbox(value: values[family[index]], onChanged: (bool newValue){
        setState(() {
            values[family[index]] = newValue;
        });
      })))),

    ]),
      index == family.length - 1 ?
      new Container(
          padding: new EdgeInsets.only(top: 45.0), child:
      new RaisedButton(onPressed: () async{
        DatabaseReference checkInReference = FirebaseDatabase.instance.reference().child("beachCheckIn/" + new DateTime.now().year.toString() + "/"+ new DateTime.now().month.toString() + "/" + new DateTime.now().day.toString());
        DatabaseReference badgeReference = FirebaseDatabase.instance.reference().child("users/" + barcode + "/badge");
        DataSnapshot badgeNumber = await badgeReference.once();
        for(final i in family)
        {
          if(values[i] == true)
          {
            await checkInReference.update({badgeNumber.value.toString() + "-" + i: new DateTime.now().hour.toString() + ":" +  new DateTime.now().minute.toString()});
          }
        }
        Navigator
            .of(context, rootNavigator: true)
            .pushNamed("/screen6");
      }, child: new Text("Check In"), color: Colors.lightBlue,)) :  new Container(height: 0.0)]);
  }
}
