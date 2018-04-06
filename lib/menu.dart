import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'userinfo.dart';
import 'dart:ui' as ui;
import 'eventsHandler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'menuCamera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:random_string/random_string.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseUser _user;
bool isHead = false;
List<Family> family = new List<Family>();
Map familyList;
Map familyChanges;
String appDocPath;
bool check = false;
EmailHandler email = new EmailHandler();
EventsListHandler eventsListHandler = new EventsListHandler();
String qr = "";
List weather;
List events;
double widthApp;
double heightApp;
double fontSize = 30.0;
DatabaseReference mainReference;
DataSnapshot snapshot;
Image profilePic;
TextEditingController _controller = new TextEditingController();
int familyLength;
final double devicePixelRatio = ui.window.devicePixelRatio;
//final QRHandler qr = new QRHandler();

class LoadingState extends StatefulWidget {
  LoadingState({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Loading createState() => new Loading();
}

class Loading extends State<LoadingState> {
  Loading() {}

  void initState() {
    _handleSignIn();
    getCameras();
    email.setEmail();
    getWeather();
    getEvents();
    getPath();

    new Future.delayed(new Duration(milliseconds: 500), _menu);
  }

  Future _menu() async {
    if (qr != null &&
        events != null &&
        weather != null &&
        cameras != null &&
        appDocPath != null &&
        _user != null) {
      Navigator.popAndPushNamed(context, "/screen5");
    } else
      new Future.delayed(new Duration(seconds: 1), _menu);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      // 1
      appBar: new AppBar(
        //2
        title: new Text("Loading",
            style: new TextStyle(fontFamily: 'Roboto', fontSize: 20.0)),
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
                          style: new TextStyle(color: Colors.lightBlue),
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

/*lass MenuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new TabbedAppBarMenu();
  }
}*/
class TabbedAppBarMenu extends StatefulWidget {
  TabbedAppBarMenu({Key key, this.title}) : super(key: key);

  final String title;

  @override
  TabbedAppBarState createState() => new TabbedAppBarState();
}

class TabbedAppBarState extends State<TabbedAppBarMenu>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: choices.length);
  }

  TabbedAppBarState() {
    mainReference.onChildChanged.listen(_familyEdited);
  }

  int changeCheck = 0;

  _familyEdited(Event event) {
    familyChanges = event.snapshot.value;
    changeCheck = 0;
    familyChanges.forEach(checkChanged);
    //var oldValue = family.singleWhere((entry) => entry.name == event.snapshot.key);
    // setState((){
    //  family[family.indexOf(oldValue)].invited = true;
    // });
  }

  void checkChanged(key, value) {
    if (familyList[key] != familyChanges[key]) {
      familyList = familyChanges;
      setState(() {
        family[changeCheck].invited = familyChanges[key];
      });
    }
    changeCheck++;
  }

  @override
  Widget build(BuildContext context) {
    email.setEmail();
    getInfo();
    getWeather();
    getEvents();
    return new MaterialApp(
      home: new DefaultTabController(
        length: choices.length,
        child: new Scaffold(
          appBar: new AppBar(
            centerTitle: true,
            title: new Text(
              'Lake Parsippany',
              textAlign: TextAlign.center,
              style: new TextStyle(fontFamily: "Roboto"),
            ),
            bottom: new TabBar(
              //isScrollable: true,
              tabs: choices.map((Choice choice) {
                return new Tab(
                  text: choice.title,
                  icon: new Icon(choice.icon),
                );
              }).toList(),
            ),
          ),
          body: new TabBarView(
            children: choices.map((Choice choice) {
              return new Padding(
                padding: const EdgeInsets.all(16.0),
                child: new ChoiceState(choice: choice),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  //const Choice(title: 'Login', icon: Icons.account_circle),
  const Choice(title: 'Check-In', icon: Icons.contacts),
  const Choice(title: 'Weather', icon: Icons.beach_access),
  const Choice(title: 'Events', icon: Icons.event),
  const Choice(title: 'Profile', icon: Icons.account_circle),
];

void deleteCred() async {
  final storage = new FlutterSecureStorage();
  await storage.delete(key: "username");
  await storage.delete(key: "password");
  await storage.delete(key: "qr");
}

Future<String> getInfo() async {
  final storage = new FlutterSecureStorage();
  String user = await storage.read(key: "username");
  qr = user;
  return user;
}

class ChoiceState extends StatefulWidget {
  ChoiceState({Key key, this.choice});

  final Choice choice;

  @override
  createState() => new ChoiceCard(choice: choice);
}

class ChoiceCard extends State<ChoiceState> {
  ChoiceCard({Key key, this.choice}) {}

  final Choice choice;
  final _saved = new Set<String>();

  @override
  Widget build(BuildContext context) {
    widthApp = MediaQuery.of(context).size.width;
    heightApp = MediaQuery.of(context).size.height;
    fontSize = (widthApp / 18).round() * 1.0;
    if (choice.title == "Check-In") {
      print("CHECK IN");
      if (qr == "") {
        return new ListView(children: <Widget>[
          new Container(
            padding: const EdgeInsets.symmetric(horizontal: 125.0),
            child: new RaisedButton(
                onPressed: () {
                  //runApp(new MenuApp());
                },
                child: new Text('Reload')),
          )
        ]);
      } else {
        return new Center(
          child: new QrImage(data: qr, size: widthApp / 2),
        );
      }
    } else if (choice.title == "Weather") {
      print("Weather");
      if (weather == null) {
        return new ListView(children: <Widget>[
          new Container(
            padding: const EdgeInsets.symmetric(horizontal: 125.0),
            child: new RaisedButton(
                onPressed: () async {
                  weather = await email.getWeather();
                },
                child: new Text('Reload')),
          )
        ]);
      } else {
        String weatherImg;
        Color barColor;
        String alertText;
        //CHECK SERVER FOR BEACH STATUS OR ON PULL WITH WEATHER
        bool open = true;
        if (open) {
          barColor = Colors.green;
          alertText = "Open";
        } else {
          barColor = Colors.red;
          alertText = "Closed";
        }

        switch (weather[0].toString()) {
          case "Clouds":
            weatherImg = 'assets/Cloud.png';
            break;

          case "Thunderstorm":
            weatherImg = 'assets/Thunder.png';
            break;

          case "Drizzle":
            weatherImg = 'assets/Rain.png';
            break;

          case "Rain":
            weatherImg = 'assets/Rain.png';
            break;
          case "Snow":
            weatherImg = 'assets/Snow.png';
            break;

          case "Clear":
            weatherImg = 'assets/Sun.png';
            break;

          default:
            weatherImg = "assets/Sun.png";
            break;
        }

        return new Card(
            color: Colors.white,
            //child: new Container(
            child: new ListView(children: [
              new Container(
                width: widthApp,
                height: 45.0,
                color: barColor,
                child: new Center(
                  child: new Text(alertText,
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                          fontSize: fontSize, fontFamily: "Alert")),
                ),
              ),
              new Image.asset(
                weatherImg,
                height: heightApp / 3.0,
                width: widthApp / 3.0,
                fit: BoxFit.contain,
              ),
              new Container(
                padding: new EdgeInsets.only(top: heightApp / 20.0),
                alignment: Alignment.center,
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                        child: new Center(
                            child: new Text(
                      "Temp:\n" +
                          weather[2].round().toString() +
                          "\u00b0" +
                          "F",
                      style:
                          new TextStyle(fontSize: 45.0, fontFamily: "Raleway"),
                      textAlign: TextAlign.center,
                    ))),
                    new Expanded(
                      child: new Center(
                          child: new Text(
                        "Wind:\n" + weather[3].round().toString() + " mph",
                        style: new TextStyle(
                            fontSize: 45.0, fontFamily: "Raleway"),
                        textAlign: TextAlign.center,
                      )),
                    )
                  ],
                ),
              ),
            ]));
        // with winds of " + weather[3].round().toString() + " mph. " + "\u000a\u000a
      }
    } else if (choice.title == "Events") {
      print("Events");
      if (events == null) {
        return new ListView(children: <Widget>[
          new Container(
            padding: const EdgeInsets.symmetric(horizontal: 125.0),
            child: new RaisedButton(
                onPressed: () async {
                  events = await eventsListHandler.getEvents();
                },
                child: new Text('Reload')),
          )
        ]);
      } else {
        //MAYBE USE CARDS? CHECK EXAMPLE

        return new ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return new GestureDetector(
              onLongPress: () {
                setState(() {
                  if (_saved.contains((events[index]['name']))) {
                    _saved.remove(events[index]['name']);
                    print("Remove");
                  } else {
                    _saved.add(events[index]['name']);
                    print("Add");
                  }
                });
              },
              child: new Card(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new ExpansionTile(
                      leading: new Text((events[index]['eventDate'])
                          .toString()
                          .substring(5, 10)),
                      title: new Text(
                        (events[index]['name']).toString(),
                        textAlign: TextAlign.left,
                      ),
                      trailing: new Icon(
                          _saved.contains(events[index]['name'])
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _saved.contains(events[index]['name'])
                              ? Colors.red
                              : null),
                      children: <Widget>[
                        new Container(
                          padding: new EdgeInsets.only(
                              left: 16.0, right: 16.0, bottom: 16.0),
                          child: new Text((events[index]['description'])),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          itemCount: events.length,
          //new EventsPage(),
        );
      }
    } else if (choice.title == 'Profile') {
      print("Profile");
      ImageProvider imageProvider;
      try {
        imageProvider = new FileImage(new File(appDocPath));
      } catch (e) {
        imageProvider = new AssetImage("/assets/nouser.png");
      }
      List<Widget> children = new List.generate(
          family.length, (int i) => new FamilyWidget(i, context));
      return new ListView(
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Expanded(
                child: new Column(children: <Widget>[
                  new Center(
                    child: new CircleAvatar(
                      backgroundImage: imageProvider,
                      radius: widthApp / 7,
                    ),
                    //child: new Image(image: new FileImage(new File(appDocPath))),
                  ),
                  new IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        child: new AlertDialog(
                          title: new Text("Where's My Profile Picture?"),
                          content: new Text(
                              'Your picture will show up after it has been taken by the Beach Manager or Membership Team'),
                        ),
                      );
                    },
                    icon: new Icon(Icons.help_outline),
                  )
                ]),
              ),
              new Expanded(
                child: new Column(children: <Widget>[
                  new Text(_user.displayName,
                      style: new TextStyle(
                          fontFamily: 'Roboto', fontSize: fontSize)),
                  new Text(snapshot.value['email'],
                      style: new TextStyle(
                          fontFamily: 'Roboto', fontSize: fontSize * .75)),
                  new Text(snapshot.value['type'] + " Membership",
                      style: new TextStyle(
                          fontFamily: 'Roboto', fontSize: fontSize * .75)),
                  new Text(
                      "Guest Badges - " + snapshot.value['guests'].toString(),
                      style: new TextStyle(
                          fontFamily: 'Roboto', fontSize: fontSize * .75)),
                ]),
              ),
            ],
          ),
          new Column(children: children),
          new Align(
              heightFactor: 3.2,
              alignment: Alignment.bottomCenter,
              child: new FlatButton(
                  onPressed: () {},
                  child: new Text(
                    "Sign-Out",
                    style: new TextStyle(
                        fontFamily: 'Roboto',
                        color: Colors.lightBlue,
                        fontSize: 20.0),
                    textAlign: TextAlign.center,
                  )))
        ],
      );
    } else {
      return new Container(width: 0.0, height: 0.0);
    }
  }
}

class FamilyWidget extends StatelessWidget {
  final int index;

  FamilyWidget(this.index, BuildContext c);

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Expanded(
          child: new Container(
            padding: new EdgeInsets.only(left: 5.0),
            child: new Text(family[index].name,
                style: new TextStyle(fontFamily: 'Roboto', fontSize: 20.0)),
          ),
        ),
        isHead
            ? new Align(
                alignment: Alignment.bottomRight,
                child: family[index].invited == "v"
                    ? new Container(
                        padding: const EdgeInsets.only(right: 30.0),
                        child: new Icon(
                          Icons.check,
                          color: Colors.lightBlue,
                        ))
                    : new FlatButton(
                        onPressed: () {
                          if (family[index].invited == 'nv') {
                            Navigator.of(context).push(new MaterialPageRoute(
                              builder: (BuildContext context) {
                                return new InviteUserDialog(index);
                              },
                            ));
                            /*if(invited == "done")
                  {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      child: new AlertDialog(
                          title: new Text("Success!"),
                          content: new Text(
                              family[index].name + " has been invited."),
                          actions: <Widget>[
                            new FlatButton(
                                child: new Text('Okay'),
                                onPressed: () {
                                  Navigator.pop(context);
                                }
                            )
                          ]
                      ),
                    );
                  }*/
                          } else {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              child: new AlertDialog(
                                  title: new Text("Uninvite"),
                                  content: new Text(
                                      "Are you sure you want to uninvite " +
                                          family[index].name +
                                          "?"),
                                  actions: <Widget>[
                                    new FlatButton(
                                        child: new Text('Yes'),
                                        onPressed: () async {
                                          await _deleteUser(index);
                                          Navigator
                                              .of(context, rootNavigator: true)
                                              .pop();
                                          //Navigator.of(context).pop();
                                        })
                                  ]),
                            );
                          }
                        },
                        child: new Text(
                          family[index].invited != "v" &&
                                  family[index].invited != "nv"
                              ? "Uninvite"
                              : "Invite",
                          style: new TextStyle(
                              fontFamily: 'Roboto',
                              color: Colors.lightBlue,
                              fontSize: 20.0),
                          textAlign: TextAlign.center,
                        )))
            : new Container()
      ],
    );
  }
}

class InviteUserDialog extends StatelessWidget {
  int index;

  InviteUserDialog(int i) {
    index = i;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        // 1
        appBar: new AppBar(
          //2
          title: new Text("Enter Email",
              style: new TextStyle(fontFamily: 'Roboto', fontSize: 20.0)),
        ),
        body: new ListView(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0),
            children: <Widget>[
              new Row(
                children: <Widget>[
                  new Flexible(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text(
                            '\n\nPlease Enter ' +
                                family[index].name +
                                "'s Email Address",
                            style: new TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 30.0,
                                color: Colors.black),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ],
              ),
              new Column(
                children: <Widget>[
                  new Container(
                    //child: new Align(
                    //heightFactor: 5.0,
                    padding: const EdgeInsets.only(top: 100.0),
                    //alignment: Alignment.center,
                    child: new TextField(
                      controller: _controller,
                      decoration: new InputDecoration(
                        hintText: 'example@example.com',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  new Align(
                    heightFactor: 2.0,
                    alignment: Alignment.bottomCenter,
                    child: new FlatButton(
                      child: new Text("Add",
                          style: new TextStyle(
                              fontFamily: 'Roboto', fontSize: 15.0)),
                      onPressed: () async {
                        //login = new ServerHandle(_controller.text, _controller2.text);
                        await _createUser(_controller, index)
                            .then((FirebaseUser user) {
                          if (user != null) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              child: new AlertDialog(
                                  title: new Text("Success!"),
                                  content: new Text(family[index].name +
                                      " has been invited."),
                                  actions: <Widget>[
                                    new FlatButton(
                                        child: new Text('Okay'),
                                        onPressed: () {
                                          Navigator
                                              .of(context, rootNavigator: true)
                                              .pop();
                                          Navigator.pop(context);
                                          //Navigator.of(context).pop();
                                        })
                                  ]),
                            );

                            //Navigator.of(context).pop("good");
                          } else {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              child: new AlertDialog(
                                  title: new Text('User Not Added'),
                                  content: new Text('Failed to Add User'),
                                  actions: <Widget>[
                                    new FlatButton(
                                        child: new Text('Try Again'),
                                        onPressed: () {
                                          Navigator
                                              .of(context, rootNavigator: true)
                                              .pop();
                                        })
                                  ]),
                            );
                          }
                        }).catchError((e) => print(e));
                      },
                    ),
                  ),
                ],
              ),
            ]));
  }
}

getWeather() async {
  weather = await email.getWeather();
}

getEvents() async {
  events = await eventsListHandler.getEvents();
}

Future _handleSignIn() async {
  print("MADE IT");
  final storage = new FlutterSecureStorage();
  String uName = await storage.read(key: "username");
  String pass = await storage.read(key: "password");
  FirebaseUser user =
      await _auth.signInWithEmailAndPassword(email: uName, password: pass);
  mainReference =
      FirebaseDatabase.instance.reference().child("users/" + user.displayName);
  snapshot = await mainReference.once();
  familyList = snapshot.value['family'];
  isHead = snapshot.value['isHead'];
  if (familyList != null) {
    familyList.forEach(createFamily);
  }
  //print(mainReference.equalTo(user.uid));
  _user = user;
  print(user);
  return user;
}

void createFamily(key, value) {
  family.add(new Family(key, value));
}

class Family {
  String name;
  String invited;

  Family(String n, String i) {
    name = n;
    invited = i;
  }
}

Future getPath() async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  appDocPath = appDocDir.path;
  appDocPath = appDocPath + "/profile.png";
}

Future<FirebaseUser> _createUser(
    TextEditingController controller, int index) async {
  String pass = randomAlphaNumeric(12);
  FirebaseUser newUser = await _auth.createUserWithEmailAndPassword(
      email: controller.text, password: pass);
  newUser = await _auth.signInWithEmailAndPassword(
      email: controller.text, password: pass);
  UserUpdateInfo uinfo = new UserUpdateInfo();
  uinfo.displayName = family[index].name;
  _auth.updateProfile(uinfo);
  if (newUser != null) {
    mainReference
        .child("/family/")
        .update({family[index].name: controller.text});
  }
  return newUser;
}

Future<FirebaseUser> _deleteUser(int index) async {
  /*NYI in library
  Maybe create web function and add call to that.
   */
  mainReference.child("/family/").update({family[index].name: "nv"});
}
