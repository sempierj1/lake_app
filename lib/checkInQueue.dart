import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'queue.dart';
import 'membershipTextStyles.dart';

final MembershipTextStyle myStyle = new MembershipTextStyle();

/*class CheckInQueue extends StatelessWidget {

  final Queue myQueue;
  final int index;

  CheckInQueue(this.myQueue, this.index);

  @override
  Widget build(BuildContext context) {
    return new Card(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        ListTile(
        leading: Text((myQueue.queue[index][2])
            .toString()),title: Text(myQueue.queue[index][1].toString()),
    trailing: Text
    (myQueue.queue[index
    ][0].toString
    ()),
    ),
    !myQueue.checked[index] ?
    ButtonTheme.bar(
    child: ButtonBar(
    children: <Widget>[
    FlatButton(
    onPressed: () async
    {
    DatabaseReference checkInReference =
    FirebaseDatabase
        .instance
        .reference()
        .child("beachCheckIn/" +
    new DateTime.now().year.toString() +
    "/" +
    new DateTime.now()
        .month
        .toString() +
    "/" +
    new DateTime.now().day.toString() +
    "/" +
    myQueue
        .queue[index]
    [2]
        .toString());
    checkInReference.update({
    myQueue.queue[index][0]:
    myQueue.queue[index][1]
    });
    DatabaseReference countReference =
    FirebaseDatabase.instance.reference().child(
    "beachCheckIn/" +
    new DateTime.now().year.toString() +
    "/" +
    new DateTime.now()
        .month
        .toString() +
    "/" +
    new DateTime.now().day.toString());
    DataSnapshot countSnapShot =
    await countReference.once();
    int tempHour = int.parse(myQueue
        .queue[index][1]);
    int tempCount = 0;
    if (tempHour > 12) {
    tempHour -= 12;
    }
    int secondHour = tempHour + 1;
    if (secondHour > 12) {
    secondHour = 1;
    }
    try {
    tempCount = countSnapShot.value[
    tempHour.toString() +
    "-" +
    secondHour.toString()];
    } catch (e) {
    tempCount = 0;
    }
    if (tempCount == null) {
    tempCount = 0;
    }
    tempCount += int.parse(myQueue
        .queue[index][0]);

    await countReference.update({
    tempHour.toString() +
    "-" +
    secondHour.toString(): tempCount
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
    tempRawCount += int.parse(myQueue
        .queue[index][0]);
    await countReference
        .update({
    'raw': tempRawCount
    });
    myQueue.checked[index] = true;
    }
    ,
    child: Text("Check-In")),

    FlatButton(
        onPressed: () {
          showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) =>
              new AlertDialog(
                title: Text("Remove From Queue?"),
                content: new Text("Are You Sure?"),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () async{

                        myQueue.queue.removeAt(index);
                      },
                      child: Text("Remove"))
                ],
              ));
        },
        child: Text("Remove"))

    ]
    ,
    )
    ): Container(width: 0.0, height: 0.0)
    ]
    ,
    )
    ,
    );
  }
}
/*
class LoadingQueueState extends StatefulWidget {
  LoadingQueueState({Key key, this.title}) : super(key: key);

  final String title;

  @override
  LoadingQueue createState() => new LoadingQueue();
}

class LoadingQueue extends State<LoadingQueueState> {
  LoadingQueue();

  int count = 0;

  //Retrieve information needed from various classes
  @override
  void initState() {
    super.initState();
    myQueue.getQueue();
    new Future.delayed(new Duration(milliseconds: 500), _menu);
  }

  /*Checks if information collection is complete, if it is, it will push the main screen of the application, otherwise it will wait 1 second and check again
    If 10 seconds pass and information collection is not finished it will prompt the user to login again.
    Collection generally takes between 2 and 5 seconds to complete, depending on connection speed.
   */
  Future _menu() async {
    if (myQueue.queueKeys != null && myQueue.queue != null) {
      if (myQueue.queueKeys.length != 0) {
        Navigator.pushReplacementNamed(context, "/screen10");
      }
    } else {
      count++;
      print(count);
      if (count > 10) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => new AlertDialog(
                title: Text("Load Failed"),
                content: Text("Load Failed Or No One has Signed In- Try Again"),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.popAndPushNamed(context, "/screen6");
                      },
                      child: Text("Try Again",
                          style: myStyle.smallFlatButton(context)))
                ],
              ),
        );
      } else {
        new Future.delayed(new Duration(seconds: 1), _menu);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      // 1
      appBar: new AppBar(
        //2
        title: new Text("Loading", style: myStyle.normalText(context)),
      ),
      body: new Container(
        child: new Stack(
          children: <Widget>[
            new Container(
              alignment: AlignmentDirectional.center,
              decoration: new BoxDecoration(
                color: Colors.white,
              ),
              child: new Container(
                decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.circular(10.0)),
                width: 300.0,
                height: 200.0,
                alignment: AlignmentDirectional.center,
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Center(
                      child: new SizedBox(
                        height: 50.0,
                        width: 50.0,
                        child: new CircularProgressIndicator(
                          value: null,
                          strokeWidth: 7.0,
                        ),
                      ),
                    ),
                    new Container(
                      margin: const EdgeInsets.only(top: 25.0),
                      child: new Center(
                        child: new Text(
                          "Loading",
                          style: myStyle.banner(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckInQueue extends StatefulWidget {
  CheckInQueue({Key key, this.title}) : super(key: key);

  final String title;

  final Map<String, dynamic> pluginParameters = {};

  @override
  _CheckInQueue createState() => new _CheckInQueue();
}

//Checks if a uid has been provided, if not, user will be prompted for one before continuing.
//Once a uid has been provided it will load the family members associated with that badge.

class _CheckInQueue extends State<CheckInQueue> {
  _CheckInQueue();

  DatabaseReference queueReference =
      FirebaseDatabase.instance.reference().child("queue");
  DataSnapshot queueSnapShot;

  @override
  initState() {
    super.initState();
  }

  List<Widget> children;
  TextEditingController _controller = new TextEditingController();
  TextEditingController _controller2 = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Check-In Queue'),
        ),
        body: myQueue.queueKeys == null || myQueue.queueKeys.length == 0
            ? Container(width: 50.0, height: 50.0, child: Text("No Signins"))
            : ListView.builder(
                itemCount: myQueue.queueKeys.length,
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                          child: Text("Badge - " +
                              myQueue.queue[myQueue.queueKeys[index]][2][0])),
                      Expanded(
                          child: Text(myQueue.queue[myQueue.queueKeys[index]][0]
                                  [0] +
                              " person(s)")),
                      Expanded(
                          child: FlatButton(
                              onPressed: () async {
                                DatabaseReference checkInReference =
                                    FirebaseDatabase
                                        .instance
                                        .reference()
                                        .child("beachCheckIn/" +
                                            new DateTime.now().year.toString() +
                                            "/" +
                                            new DateTime.now()
                                                .month
                                                .toString() +
                                            "/" +
                                            new DateTime.now().day.toString() +
                                            "/" +
                                            myQueue
                                                .queue[myQueue.queueKeys[index]]
                                                    [2][0]
                                                .toString());
                                checkInReference.update({
                                  myQueue.queue[myQueue.queueKeys[index]][0][0]:
                                      myQueue.queue[myQueue.queueKeys[index]][1]
                                          [0]
                                });
                                DatabaseReference countReference =
                                    FirebaseDatabase.instance.reference().child(
                                        "beachCheckIn/" +
                                            new DateTime.now().year.toString() +
                                            "/" +
                                            new DateTime.now()
                                                .month
                                                .toString() +
                                            "/" +
                                            new DateTime.now().day.toString());
                                DataSnapshot countSnapShot =
                                    await countReference.once();
                                int tempHour = int.parse(myQueue
                                    .queue[myQueue.queueKeys[index]][1][0]);
                                int tempCount = 0;
                                if (tempHour > 12) {
                                  tempHour -= 12;
                                }
                                int secondHour = tempHour + 1;
                                if (secondHour > 12) {
                                  secondHour = 1;
                                }
                                try {
                                  tempCount = countSnapShot.value[
                                      tempHour.toString() +
                                          "-" +
                                          secondHour.toString()];
                                } catch (e) {
                                  tempCount = 0;
                                }
                                if (tempCount == null) {
                                  tempCount = 0;
                                }
                                tempCount += int.parse(myQueue
                                    .queue[myQueue.queueKeys[index]][0][0]);

                                await countReference.update({
                                  tempHour.toString() +
                                      "-" +
                                      secondHour.toString(): tempCount
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
                                tempRawCount += int.parse(myQueue
                                    .queue[myQueue.queueKeys[index]][0][0]);
                                await countReference
                                    .update({'raw': tempRawCount});
                                await queueReference
                                    .child(myQueue.queueKeys[index])
                                    .remove();
                                myQueue.queueKeys.removeAt(index);
                                print(myQueue.queueKeys);
                                if (myQueue.queueKeys.length == 0) {
                                  Navigator.popAndPushNamed(
                                      context, "/screen5");
                                } else {
                                  setState(() {});
                                }
                              },
                              child: Text("Check-In"))),
                      Expanded(
                          child: FlatButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (BuildContext context) =>
                                        new AlertDialog(
                                          title: Text("Remove From Queue?"),
                                          content: new Text("Are You Sure?"),
                                          actions: <Widget>[
                                            FlatButton(
                                                onPressed: () async {
                                                  await queueReference
                                                      .child(myQueue
                                                          .queueKeys[index])
                                                      .remove();
                                                  myQueue.queueKeys.removeAt(index);
                                                  print(myQueue.queueKeys);
                                                  if (myQueue
                                                          .queueKeys.length ==
                                                      0) {
                                                    Navigator.popAndPushNamed(
                                                        context, "/screen5");
                                                  } else {
                                                    setState(() {
                                                      Navigator.pop(context);
                                                    });
                                                  }
                                                },
                                                child: Text("Remove"))
                                          ],
                                        ));
                              },
                              child: Text("Remove")))
                    ],
                  );
                },
              ));
  }
}*/
*/