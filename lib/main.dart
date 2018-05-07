import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:ui' as ui;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'menuCamera.dart';
import 'qrScan.dart';
import 'badgeNumber.dart';
import 'membershipTextStyles.dart';
import 'userInfo.dart';
import 'familyWidget.dart';
import 'serverFunctions.dart';
import 'events.dart';
import 'weather.dart';

final MembershipTextStyle myStyle = new MembershipTextStyle();
final AppUserInfo userInfo = new AppUserInfo();
final ServerFunctions serverFunctions = new ServerFunctions();
final Events eventHandler = new Events();
final Weather weatherHandler = new Weather();
final double devicePixelRatio = ui.window.devicePixelRatio;

void main() {
  runCheck();
}

void runCheck() async {
  bool check = await checkFirstRun();
  if (check) {
    runApp(new MaterialApp(
      home: new FirstScreen(),
      routes: <String, WidgetBuilder>{
        '/screen1': (BuildContext context) => new FirstScreen(),
        '/screen2': (BuildContext context) => new EnterEmail(),
        '/screen3': (BuildContext context) => new Login(),
        '/screen5': (BuildContext context) => new TabbedAppBarMenu(),
        '/screen6': (BuildContext context) => new LoadingState(),
        '/screen7': (BuildContext context) => new CameraState(),
        '/screen8': (BuildContext context) => new QrScanner(),
        '/screen9': (BuildContext context) => new BadgeNumber(),
      },
    ));
  } else {
    runApp(new MaterialApp(
      home: new LoadingState(),
      routes: <String, WidgetBuilder>{
        '/screen1': (BuildContext context) => new FirstScreen(),
        '/screen2': (BuildContext context) => new EnterEmail(),
        '/screen3': (BuildContext context) => new Login(),
        '/screen5': (BuildContext context) => new TabbedAppBarMenu(),
        '/screen6': (BuildContext context) => new LoadingState(),
        '/screen7': (BuildContext context) => new CameraState(),
        '/screen8': (BuildContext context) => new QrScanner(),
        '/screen9': (BuildContext context) => new BadgeNumber(),
      },
    ));
  }
}

Future<bool> checkFirstRun() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool run = (prefs.getBool('firstRun') ?? true);
  return run;
}

bool sent = true;
int message = 0;

setPrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('firstRun', true);
}

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        // 1
        appBar: new AppBar(
          //2
          title: new Text("Getting Started",
              style: myStyle.whiteText(context)),
        ),
        body: new Column(children: <Widget>[
          new Row(
            children: <Widget>[
              new Flexible(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text('\n\nWelcome to the Lake Parsippany Phone App',
                        style: myStyle.header(context),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ],
          ),
          new Align(
            heightFactor: 5.0,
            alignment: Alignment.bottomCenter,
            child: new FlatButton(
              onPressed: () {
                // 4
                Navigator.pushNamed(context, "/screen2"); // 5
              },
              child: new Text(
                "Get Started",
                style: myStyle.banner(context),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          new Align(
            heightFactor: 5.0,
            alignment: Alignment.bottomCenter,
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(
                  "Used the App Before?",
                  style: myStyle.subText(context),
                  textAlign: TextAlign.center,
                ),
                new FlatButton(
                  onPressed: () async {
                    // 4
                    Navigator.pushNamed(context, "/screen3"); // 5
                  },
                  child: new Text(
                    "Login",
                    style: myStyle.smallFlatButton(context),
                  ),
                ),
              ],
            ),
          ),
        ]));
  }
}

class EnterEmail extends StatelessWidget {
  

  setPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('firstRun', true);
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = new TextEditingController();
    return new Scaffold(
        // 1
        appBar: new AppBar(
          //2
          title: new Text("Enter Email",
              style: myStyle.whiteText(context)),
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
                            '\n\nPlease Enter the Email Associated With Your Membership',
                            style: myStyle.header(context),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ],
              ),
              new Column(
                children: <Widget>[
                  new Form(
                    child: new Container(
                      //child: new Align(
                      //heightFactor: 5.0,
                      padding: const EdgeInsets.only(top: 100.0),
                      //alignment: Alignment.center,
                      child: new TextFormField(
                        controller: _controller,
                        decoration: new InputDecoration(
                          hintText: 'example@example.com',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  new Align(
                    heightFactor: 3.0,
                    alignment: Alignment.bottomCenter,
                    child: new FlatButton(
                        onPressed: () async {
                          sent = true;
                          await serverFunctions.resetPassword(_controller.text).catchError((e) {
                            sent = false;
                          });
                          if (sent) {
                            setPrefs();
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) =>
                                  new AlertDialog(
                                      title:
                                          new Text('Password Reset Email Sent'),
                                      content: new Text(
                                          'Please Follow the Instructions in the Email then Click Continue'),
                                      actions: <Widget>[
                                        new FlatButton(
                                            child: new Text('Continue'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.pushNamed(
                                                  context, "/screen3");
                                            })
                                      ]),
                            );
                          } else {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) =>
                                  new AlertDialog(
                                      title:
                                          new Text('Verification Email Failed'),
                                      content: new Text(
                                          'Please Be Sure to Enter the Email Associated with Your Membership'),
                                      actions: <Widget>[
                                        new FlatButton(
                                            child: new Text('Try Again'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            })
                                      ]),
                            );
                          }
                        },
                        child: new Text(
                          "Submit",
                          style: myStyle.smallFlatButton(context),
                          textAlign: TextAlign.center,
                        )),
                  ),
                ],
              ),
            ]));
  }
}

class Login extends StatelessWidget {

  @override
  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = new TextEditingController();
    TextEditingController _controller2 = new TextEditingController();
    return new Scaffold(
        // 1
        appBar: new AppBar(
          //2
          title: new Text("Enter Email",
              style: myStyle.whiteText(context)),
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
                            '\n\nPlease Enter Your Email Address and Password',
                            style: myStyle.header(context),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ],
              ),
              new Column(
                children: <Widget>[
                  new Container(
                    padding: const EdgeInsets.only(top: 100.0),
                    child: new TextField(
                      controller: _controller,
                      decoration: new InputDecoration(
                        hintText: 'example@example.com',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  new Container(
                    //alignment: Alignment.center,
                    child: new TextField(
                      controller: _controller2,
                      decoration: new InputDecoration(
                        hintText: 'Password',
                      ),
                      textAlign: TextAlign.center,
                      obscureText: true,
                    ),
                  ),
                  new Align(
                    heightFactor: 2.0,
                    alignment: Alignment.bottomCenter,
                    child: new FlatButton(
                        onPressed: () async {
                          await userInfo.handleSignIn(_controller.text, _controller2.text)
                              .then((FirebaseUser user) {
                            if (user != null) {
                              Navigator.pushReplacementNamed(
                                  context, "/screen6");
                            } else {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) =>
                                    new AlertDialog(
                                        title: new Text('Login Failed'),
                                        content: new Text(
                                            'Login Credentials Are Case Sensitive'),
                                        actions: <Widget>[
                                          new FlatButton(
                                              child: new Text('Try Again'),
                                              onPressed: () {
                                                _controller2.text = "";
                                                Navigator.pop(context);
                                              })
                                        ]),
                              );
                            }
                          }).catchError((e) => print(e));
                        },
                        child: new Text(
                          "Submit",
                          style: myStyle.smallFlatButton(context),
                          textAlign: TextAlign.center,
                        )),
                  ),
                ],
              ),
            ]));
  }
}



class LoadingState extends StatefulWidget {
  LoadingState({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Loading createState() => new Loading();
}

class Loading extends State<LoadingState> {
  Loading();

  @override
  void initState() {
    super.initState();
    if(!userInfo.signedIn) {
      userInfo.handleSignInMain();
    }
    weatherHandler.getWeather();
    eventHandler.getEvents();
    new Future.delayed(new Duration(milliseconds: 500), _menu);
  }

  Future _menu() async {
    if ((eventHandler.events != null &&
            weatherHandler.finished != null &&
            userInfo.user != null &&
            userInfo.imageProvider != null) ||
        (userInfo.isBeach)) {
      Navigator.pushReplacementNamed(context, "/screen5");
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
            style: myStyle.normalText(context)),
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

class TabbedAppBarMenu extends StatefulWidget {
  TabbedAppBarMenu({Key key, this.title}) : super(key: key);

  final String title;

  @override
  TabbedAppBarState createState() => new TabbedAppBarState();
}

class TabbedAppBarState extends State<TabbedAppBarMenu>
    with SingleTickerProviderStateMixin {
  final DatabaseReference listenerReference = userInfo.isBeach
      ? null
      : FirebaseDatabase.instance.reference().child("users/" + userInfo.user.uid);

  final DatabaseReference beachListener = userInfo.isBeach
      ? null
      : FirebaseDatabase.instance.reference().child("beach status");

  final DatabaseReference weatherListener =
      userInfo.isBeach ? null : FirebaseDatabase.instance.reference().child("weather");

  final DatabaseReference weatherClosureListener = userInfo.isBeach
      ? null
      : FirebaseDatabase.instance.reference().child("weatherDelay");

  Map familyChanges;

  TabbedAppBarState() {
    if (!userInfo.isBeach) {
      listenerReference.onChildChanged.listen(_familyEdited);
      beachListener.onValue.listen(_editBeachStatus);
      weatherListener.onValue.listen(_editWeather);
      weatherClosureListener.onValue.listen(_editWeatherClosure);
    }
  }

  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print("Push Messaging token: $token");
    });
    _firebaseMessaging.subscribeToTopic("beach");
    _firebaseMessaging.configure(onLaunch: (Map<String, dynamic> message) {
      goToWeather();
    }, onResume: (Map<String, dynamic> message) {
      goToWeather();
    }, onMessage: (Map<String, dynamic> message) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => new AlertDialog(
                title: new Text("Beach Status Update"),
                content: new Text(message['body'].toString()),
                actions: <Widget>[
                  new FlatButton(
                      child: new Text('Okay'),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        //Navigator.of(context).pop();
                      })
                ]),
      );
    });
  }

  void goToWeather() {
    Navigator.pushNamed(context, "/screen6");
  }

  int changeCheck = 0;

  _editWeather(Event event) {
    try {
      setState(() {
        weatherHandler.weather = event.snapshot.value;
        weatherHandler.weatherDescription = weatherHandler.weather['longDesc'].toString().split(" ");
        weatherHandler.weatherDescriptionFixed = "";
        for (final i in weatherHandler.weatherDescription) {
          if (weatherHandler.weatherDescriptionFixed != "") {
            weatherHandler.weatherDescriptionFixed += " ";
          }
          weatherHandler.weatherDescriptionFixed += i.substring(0, 1).toUpperCase();
          weatherHandler.weatherDescriptionFixed += i.substring(1, i.length);
        }
      });
    } catch (e) {}
  }

  _editWeatherClosure(Event event) {
    try {
      setState(() {
        weatherHandler.weatherClosure = event.snapshot.value == "true" ? true : false;
      });
    } catch (e) {}
  }

  _editBeachStatus(Event event) {
    String status;
    try {
      status = event.snapshot.value;
      setState(() {
        weatherHandler.beachOpen = status == "open" ? true : false;
      });
    } catch (e) {}
  }

  _familyEdited(Event event) {
    try {
      familyChanges = event.snapshot.value;
      changeCheck = 0;
      familyChanges.forEach(checkChanged);
    } catch (e) {}
  }

  void checkChanged(key, value) {
    if (userInfo.familyList[key] != familyChanges[key]) {
      userInfo.familyList = familyChanges;
      setState(() {
        userInfo.family[changeCheck].invited = familyChanges[key];
      });
    }
    changeCheck++;
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new DefaultTabController(
        length: userInfo.isManager
            ? choicesManager.length
            : userInfo.isBeach ? choicesBeach.length : choices.length,
        child: new Scaffold(
          appBar: new AppBar(
            centerTitle: true,
            title: new Text(
              'Lake Parsippany',
              textAlign: TextAlign.center,
              style: myStyle.whiteText(context),
            ),
            bottom: new TabBar(
              //isScrollable: true,
              tabs: userInfo.isManager
                  ? choicesManager.map((Choice choice) {
                      return new Tab(
                        text: choice.title,
                        icon: new Icon(choice.icon),
                      );
                    }).toList()
                  : userInfo.isBeach
                      ? choicesBeach.map((Choice choice) {
                          return new Tab(
                            text: choice.title,
                            icon: new Icon(choice.icon),
                          );
                        }).toList()
                      : choices.map((Choice choice) {
                          return new Tab(
                            text: choice.title,
                            icon: new Icon(choice.icon),
                          );
                        }).toList(),
            ),
          ),
          body: new TabBarView(
            children: userInfo.isManager
                ? choicesManager.map((Choice choice) {
                    return new Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: new ChoiceState(choice: choice),
                    );
                  }).toList()
                : userInfo.isBeach
                    ? choicesBeach.map((Choice choice) {
                        return new Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: new ChoiceState(choice: choice),
                        );
                      }).toList()
                    : choices.map((Choice choice) {
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
  const Choice(title: 'Check-In', icon: Icons.contacts),
  const Choice(title: 'Weather', icon: Icons.beach_access),
  const Choice(title: 'Events', icon: Icons.event),
  const Choice(title: 'Profile', icon: Icons.account_circle),
];

const List<Choice> choicesManager = const <Choice>[
  const Choice(title: 'Check-In', icon: Icons.contacts),
  const Choice(title: 'Weather', icon: Icons.beach_access),
  const Choice(title: 'Events', icon: Icons.event),
  const Choice(title: 'Profile', icon: Icons.account_circle),
  const Choice(title: 'Manager', icon: Icons.vpn_key)
];

const List<Choice> choicesBeach = const <Choice>[
  const Choice(title: 'Sign-In', icon: Icons.image),
];

void deleteCred() async {
  final storage = new FlutterSecureStorage();
  await storage.delete(key: "username");
  await storage.delete(key: "password");
}

Future<String> getInfo() async {
  final storage = new FlutterSecureStorage();
  String user = await storage.read(key: "username");
  return user;
}

class ChoiceState extends StatefulWidget {
  ChoiceState({Key key, this.choice});

  final Choice choice;

  @override
  createState() => new ChoiceCard(choice: choice);
}

class ChoiceCard extends State<ChoiceState> {
  ChoiceCard({Key key, this.choice});

  final Choice choice;

  @override
  Widget build(BuildContext context) {
    widthApp = MediaQuery.of(context).size.width;
    heightApp = MediaQuery.of(context).size.height;
    myStyle.fontSize = (widthApp / 18).round() * 1.0;
    if (choice.title == "Check-In") {
      return new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: new QrImage(version: 3, data: userInfo.user.uid, size: widthApp / 2),
          ),
          Container(
              padding: const EdgeInsets.only(top: 50.0),
              child: Center(
                  child: new Text(userInfo.badgeNumber.toString(),
                      style: new TextStyle(
                          fontFamily: "Raleway", fontSize: myStyle.fontSize*3))))
        ],
      );
    } else if (choice.title == "Weather") {
      if (weatherHandler.weather == null) {
        return new ListView(children: <Widget>[
          new Container(
            padding: const EdgeInsets.symmetric(horizontal: 125.0),
            child: new RaisedButton(
                onPressed: () async {
                  //weatherHandler.weather = await email.getWeather();
                },
                child: new Text('Reload')),
          )
        ]);
      } else {
        String weatherImg;
        Color barColor;
        String alertText;
        if (weatherHandler.beachOpen && !weatherHandler.weatherClosure) {
          barColor = Colors.green;
          alertText = "Open";
        } else if (!weatherHandler.beachOpen && !weatherHandler.weatherClosure) {
          barColor = Colors.blueAccent;
          alertText = "Closed - Off Hours";
        } else {
          barColor = Colors.red;
          alertText = "Closed - Inclement Weather";
        }

        switch (weatherHandler.weather['icon'].toString()) {
          case "03n":
            weatherImg = 'assets/png/03d.png';
            break;

          case "04d":
            weatherImg = 'assets/png/03d.png';
            break;

          case "04n":
            weatherImg = 'assets/png/03d.png';
            break;

          case "09n":
            weatherImg = 'assets/png/09d.png';
            break;
          case "11n":
            weatherImg = 'assets/png/11d.png';
            break;

          case "13n":
            weatherImg = 'assets/png/13d.png';
            break;

          default:
            weatherImg = "assets/png/" + weatherHandler.weather['icon'].toString() + ".png";
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
                          fontSize: myStyle.fontSize, fontFamily: "Alert")),
                ),
              ),
              new Container(
                height: heightApp / 3,
                width: widthApp / 3,
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: new Image.asset(
                  weatherImg,
                  height: heightApp / 3.5,
                  width: widthApp / 3.5,
                  fit: BoxFit.contain,
                ),
              ),
              new Container(
                  padding: new EdgeInsets.only(top: heightApp / 30.0),
                  alignment: Alignment.center,
                  child: new Text(weatherHandler.weatherDescriptionFixed,
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                          fontSize: myStyle.fontSize, fontFamily: "Raleway"))),
              new Container(
                padding: new EdgeInsets.only(top: heightApp / 25.0),
                alignment: Alignment.center,
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                        child: new Center(
                            child: new Text(
                      "Temp:\n" +
                          weatherHandler.weather['temp'].round().toString() +
                          "\u00b0" +
                          "F",
                      style: new TextStyle(
                          fontSize: 11.25 * (heightApp / 200),
                          fontFamily: "Raleway"),
                      textAlign: TextAlign.center,
                    ))),
                    new Expanded(
                      child: new Center(
                          child: new Text(
                        "Wind:\n" + weatherHandler.weather['wind'].round().toString() + " mph",
                        style: new TextStyle(
                            fontSize: 11.25 * (heightApp / 200),
                            fontFamily: "Raleway"),
                        textAlign: TextAlign.center,
                      )),
                    )
                  ],
                ),
              ),
            ]));
        // with winds of " + weatherHandler.weather[3].round().toString() + " mph. " + "\u000a\u000a
      }
    } else if (choice.title == "Events") {
      int month = new DateTime.now().month;
      int day = new DateTime.now().day;
      List<int> current = new List();
      for (final i in eventHandler.events) {
        if (int.parse(i['eventDate'].toString()[0]) > month) {
          current.add(i['eventNum']);
        } else if (int.parse(i['eventDate'].toString()[0]) == month &&
            int.parse(i['eventDate'].toString()[2]) >= day) {
          current.add(i['eventNum']);
        }
      }
      return new Scaffold(
        appBar: new AppBar(
            elevation: 0.0,
            backgroundColor: Colors.white,
            title: userInfo.favorites
                ? new Text(
                    (current.length - userInfo.saved.length).toString() +
                        " events hidden",
                    style: new TextStyle(color: Colors.black),
                  )
                : new Text(""),
            actions: <Widget>[
              new DropdownButton(
                  hint: userInfo.favorites
                      ? new Text("Favorites Only")
                      : eventHandler.showCurrent
                          ? new Text("Upcoming")
                          : new Text("Show All"),
                  items: <String>["Upcoming", "Favorites Only", "Show All"]
                      .map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      if (v == "Show All") {
                        userInfo.toggleFavorite(false);
                        userInfo.favorites = false;
                        eventHandler.showCurrent = false;
                      } else if (v == "Favorites Only") {
                        userInfo.toggleFavorite(true);
                        userInfo.favorites = true;
                        eventHandler.showCurrent = true;
                      } else {
                        userInfo.toggleFavorite(false);
                        userInfo.favorites = false;
                        eventHandler.showCurrent = true;
                      }
                    });
                  }),
            ]),
        body: new ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return new GestureDetector(
                onLongPress: () {
                  setState(() {
                    if (userInfo.saved.contains((eventHandler.events[index]['eventNum']))) {
                      userInfo.saved.remove(eventHandler.events[index]['eventNum']);
                      eventHandler.handleEvent(
                          eventHandler.events[index]['eventNum'],
                          'remove',
                          eventHandler.events[index]['eventDate'],
                          eventHandler.events[index]['eventName'],
                      userInfo);
                    } else {
                      userInfo.saved.add(eventHandler.events[index]['eventNum']);
                      eventHandler.handleEvent(
                          eventHandler.events[index]['eventNum'],
                          'add',
                          eventHandler.events[index]['eventDate'],
                          eventHandler.events[index]['eventName'],
                      userInfo);
                    }
                  });
                },
                child: eventHandler.showCurrent
                    ? current.contains(eventHandler.events[index]['eventNum'])
                        ? !userInfo.favorites
                            ? new Card(
                                child: new Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    new ExpansionTile(
                                      leading: new Text(
                                          (eventHandler.events[index]['eventDate'])),
                                      title: new Text(
                                        (eventHandler.events[index]['eventName']).toString(),
                                        textAlign: TextAlign.left,
                                      ),
                                      trailing: new Icon(
                                          userInfo.saved.contains(
                                                  eventHandler.events[index]['eventNum'])
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: userInfo.saved.contains(
                                                  eventHandler.events[index]['eventNum'])
                                              ? Colors.red
                                              : null),
                                      children: <Widget>[
                                        new Container(
                                          padding: new EdgeInsets.only(
                                              left: 16.0,
                                              right: 16.0,
                                              bottom: 16.0),
                                          child: new Text((eventHandler.events[index]
                                              ['eventDescription'])),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : (userInfo.saved.contains(eventHandler.events[index]['eventNum'])
                                ? new Card(
                                    child: new Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        new ExpansionTile(
                                          leading: new Text(
                                              (eventHandler.events[index]['eventDate'])),
                                          title: new Text(
                                            (eventHandler.events[index]['eventName'])
                                                .toString(),
                                            textAlign: TextAlign.left,
                                          ),
                                          trailing: new Icon(
                                              userInfo.saved.contains(
                                                      eventHandler.events[index]['eventNum'])
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: userInfo.saved.contains(
                                                      eventHandler.events[index]['eventNum'])
                                                  ? Colors.red
                                                  : null),
                                          children: <Widget>[
                                            new Container(
                                              padding: new EdgeInsets.only(
                                                  left: 16.0,
                                                  right: 16.0,
                                                  bottom: 16.0),
                                              child: new Text((eventHandler.events[index]
                                                  ['eventDescription'])),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : new Container(width: 0.0, height: 0.0))
                        : new Container(width: 0.0, height: 0.0)
                    : new Card(
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new ExpansionTile(
                              leading: new Text((eventHandler.events[index]['eventDate'])),
                              title: new Text(
                                (eventHandler.events[index]['eventName']).toString(),
                                textAlign: TextAlign.left,
                              ),
                              trailing: new Icon(
                                  userInfo.saved.contains(eventHandler.events[index]['eventNum'])
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      userInfo.saved.contains(eventHandler.events[index]['eventNum'])
                                          ? Colors.red
                                          : null),
                              children: <Widget>[
                                new Container(
                                  padding: new EdgeInsets.only(
                                      left: 16.0, right: 16.0, bottom: 16.0),
                                  child: new Text(
                                      (eventHandler.events[index]['eventDescription'])),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ));
          },
          itemCount: eventHandler.events.length,
          //new eventHandler.eventsPage(),
        ),
      );
    } else if (choice.title == 'Profile') {
      List<Widget> children = new List.generate(
          userInfo.family.length, (int i) => new FamilyWidget(i, context, userInfo));
      return new ListView(
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Expanded(
                child: new Column(children: <Widget>[
                  new Center(
                    child: new CircleAvatar(
                      backgroundImage: userInfo.imageProvider,
                      radius: widthApp / 7,
                    ),
                    //child: new Image(image: new FileImage(new File(appDocPath))),
                  ),
                  new IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) => new AlertDialog(
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
                  new Text(userInfo.user.displayName,
                      style: new TextStyle(
                          fontFamily: 'Roboto', fontSize: myStyle.fontSize)),
                  new Text(userInfo.userSnapshot.value['email'],
                      style: new TextStyle(
                          fontFamily: 'Roboto', fontSize: myStyle.fontSize * .75)),
                  new Text(userInfo.userSnapshot.value['type'] + " Membership",
                      style: new TextStyle(
                          fontFamily: 'Roboto', fontSize: myStyle.fontSize * .75)),
                  new Text(
                      "Guest Badges - " +
                          userInfo.userSnapshot.value['guests'].toString(),
                      style: new TextStyle(
                          fontFamily: 'Roboto', fontSize: myStyle.fontSize * .75)),
                ]),
              ),
            ],
          ),
          new Column(children: children),
          new Align(
              heightFactor: 3.2,
              alignment: Alignment.bottomCenter,
              child: new FlatButton(
                  onPressed: () {
                    userInfo.signOut();
                    try {
                      Navigator.of(context, rootNavigator: true).pop(context);
                    } catch (e) {}
                    try {
                      Navigator
                          .of(context, rootNavigator: true)
                          .pushReplacementNamed("/screen3");
                    } catch (e) {
                      Navigator.pushReplacementNamed(context, "/screen3");
                    }
                  },
                  child: new Text(
                    "Sign-Out",
                    style: myStyle.smallFlatButton(context),
                    textAlign: TextAlign.center,
                  )))
        ],
      );
    } else if (choice.title == "Manager") {
      return new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new RaisedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) => new AlertDialog(
                        title: weatherHandler.weatherClosure
                            ? new Text("Open the Beach?")
                            : new Text("Close the Beach?"),
                        content: weatherHandler.weatherClosure
                            ? new Text(
                                "Are you sure you want to open the beach?")
                            : new Text(
                                'Are you sure you want to close the beach?'),
                        actions: <Widget>[
                          new FlatButton(
                              onPressed: () async {
                                showDialog(context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) =>
                                    new AlertDialog(
                                      title: new Text("Sending Message"),
                                      content: new Container(
                                        height: 200.0,
                                        child: new Center(
                                          child: new SizedBox(
                                            height: 50.0,
                                            width: 50.0,
                                            child: new CircularProgressIndicator(
                                              value: null,
                                              strokeWidth: 7.0,
                                            ),
                                          ),
                                        ),),)
                                );
                                await serverFunctions.closeBeach(weatherHandler.weatherClosure);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: new Text("Confirm"))
                        ],
                      ),
                );
              },color: Colors.white,
              child: weatherHandler.weatherClosure
                  ? new Text("Open Beach", style: new TextStyle(fontSize: myStyle.fontSize),)
                  : new Text("Close Beach", style: new TextStyle(fontSize: myStyle.fontSize))),
        ],
      );
    } else if (choice.title == "Sign-In") {
      return new Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          new Row(children: <Widget>[
            new Expanded(
                child: new IconButton(
                    icon: new Icon(Icons.camera_alt),
                    iconSize: 70.0,
                    color: Colors.lightBlue,
                    onPressed: () {
                      Navigator
                          .of(context, rootNavigator: true)
                          .pushNamed("/screen8");
                    })),
            new Expanded(
                child: new FlatButton(
                    onPressed: () {
                      Navigator
                          .of(context, rootNavigator: true)
                          .pushNamed("/screen9");
                    },
                    child: new Text("Badge #",
                        style: new TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: myStyle.fontSize * 1.3,
                            color: Colors.lightBlue)))),
          ]),
          new Align(
              alignment: Alignment.bottomCenter,
              child: new FlatButton(
                  onPressed: () {
                    userInfo.signOut();
                    try {
                      Navigator.of(context, rootNavigator: true).pop(context);
                    } catch (e) {}
                    try {
                      Navigator
                          .of(context, rootNavigator: true)
                          .pushReplacementNamed("/screen3");
                    } catch (e) {
                      Navigator.pushReplacementNamed(context, "/screen3");
                    }
                  },
                  child: new Text("Sign-Out",
                      style: new TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: myStyle.fontSize * .75,
                          color: Colors.lightBlue)))),
        ],
      );
    } else {
      return new Container(width: 0.0, height: 0.0);
    }
  }
}

