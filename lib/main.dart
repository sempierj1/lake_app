import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:secure_string/secure_string.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

final FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseUser _user;
bool isHead = false;
List<Family> family = new List<Family>();
Map familyList;
Map familyChanges;
String appDocPath;
bool check = false;
Map weather;
List events;
double widthApp;
double heightApp;
double fontSize = 30.0;
bool beachOpen = true;
DatabaseReference mainReference;
DatabaseReference userReference;
DataSnapshot userSnapshot;
DataSnapshot statusSnapshot;
DataSnapshot eventSnapshot;
bool favorites = false;
bool showCurrent = true;
Image profilePic;
TextEditingController _controller = new TextEditingController();
int familyLength;
final double devicePixelRatio = ui.window.devicePixelRatio;
List<int> _saved = new List();
bool weatherClosure;
String weatherIcon;
List<String> weatherDescription;
String weatherDescriptionFixed = "";
bool isManager = false;
ImageProvider imageProvider;

TextEditingController _controller2 = new TextEditingController();

DataSnapshot snapshot;

//test
void main() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runCheck();
}

void runCheck() async {
  bool check = await checkFirstRun();
  //bool check2 = await checkInfo();
  if (check) {
    runApp(new MaterialApp(
      home: new FirstScreen(),
      routes: <String, WidgetBuilder>{
        '/screen1': (BuildContext context) => new FirstScreen(),
        '/screen2': (BuildContext context) => new EnterEmail(),
        '/screen3': (BuildContext context) => new Login(),
        //'/screen4': (BuildContext context) => new LoadScreen(),
        '/screen5': (BuildContext context) => new TabbedAppBarMenu(),
        '/screen6': (BuildContext context) => new LoadingState(),
      },
    ));
  } else {
    runApp(new MaterialApp(
      home: new LoadingState(),
      routes: <String, WidgetBuilder>{
        '/screen1': (BuildContext context) => new FirstScreen(),
        '/screen2': (BuildContext context) => new EnterEmail(),
        '/screen3': (BuildContext context) => new Login(),
        //'/screen4': (BuildContext context) => new LoadScreen(),
        '/screen5': (BuildContext context) => new TabbedAppBarMenu(),
        '/screen6': (BuildContext context) => new LoadingState(),
      },
    ));
  }
}

Future<bool> checkFirstRun() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool run = (prefs.getBool('firstRun') ?? true);
  return run;
}

/*Future<bool> checkInfo() async
{
  final storage = new FlutterSecureStorage();
  String user = await (storage.read(key: "username") ?? null);
  if (user != null) {
    return true;
  }
  else
  {
    return false;
  }
}*/
//TEST VARIABLES
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
              style: new TextStyle(fontFamily: 'Roboto', fontSize: 20.0)),
        ),
        body: new Column(children: <Widget>[
          new Row(
            children: <Widget>[
              new Flexible(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text('\n\nWelcome to the Lake Parsippany Phone App',
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
                style: new TextStyle(
                    fontFamily: 'Roboto',
                    color: Colors.lightBlue,
                    fontSize: 25.0),
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
                  style: new TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 15.0,
                      color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                new FlatButton(
                  onPressed: () async {
                    // 4
                    Navigator.pushNamed(context, "/screen3"); // 5
                  },
                  child: new Text(
                    "Login",
                    style: new TextStyle(
                        fontFamily: 'Roboto',
                        color: Colors.lightBlue,
                        fontSize: 15.0),
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
                            '\n\nPlease Enter the Email Associated With Your Membership',
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
                          await resetPassword().catchError((e) {
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
                          style: new TextStyle(
                              fontFamily: 'Roboto',
                              color: Colors.lightBlue,
                              fontSize: 15.0),
                          textAlign: TextAlign.center,
                        )),
                  ),
                ],
              ),
            ]));
  }

  Future<bool> sendEmail() async {
    var email = _controller.text;
    var url = 'https://mediahomecraft.ddns.net/lake/main.php';
    var uri = Uri.parse(url);
    try {
      var request = new MultipartRequest("POST", uri);
      request.fields['email'] = email;
      StreamedResponse response = await request.send();
      await for (var value in response.stream.transform(utf8.decoder)) {
        if (value.toString().length == 1) {
          sent = true;
        } else {
          sent = false;
        }
      }
    } catch (exception) {
      print(exception);
      sent = false;
      //Error Message Here
    }
    return sent;
  }
}

class Login extends StatelessWidget {
  @override
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
                            '\n\nPlease Enter Your Email Address and Password',
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
                          //login = new ServerHandle(_controller.text, _controller2.text);
                          await _handleSignIn(context)
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
                          //await login.checkLogin();
                          /*runApp(new MaterialApp(
                              home: new TabbedAppBarMenu(),
                              routes: <String, WidgetBuilder>{
                                '/screen1': (BuildContext context) => new TabbedAppBarMenu(),
                                '/screen2': (BuildContext context) => new LoadingState(),
                              },
                            ));*/
                        },
                        child: new Text(
                          "Submit",
                          style: new TextStyle(
                              fontFamily: 'Roboto',
                              color: Colors.lightBlue,
                              fontSize: 15.0),
                          textAlign: TextAlign.center,
                        )),
                  ),
                ],
              ),
            ]));
  }
}

Future resetPassword() async {
  await _auth.sendPasswordResetEmail(email: _controller.text).catchError((e) {
    sent = false;
  });
}

Future<FirebaseUser> _handleSignIn(BuildContext context) async {
  FirebaseUser user;
  try {
    List<String> uName = _controller.text.split(" ");
    user = await _auth.signInWithEmailAndPassword(
      email: uName[0],
      password: _controller2.text,
    );
  } catch (e) {
    print(e);
  }

  if (user != null) {
    _user = user;
    await setFirstRun();
    await storeInfo();
    try {
      mainReference = FirebaseDatabase.instance
          .reference()
          .child("users/" + user.displayName);
      mainReference.update({"email": _controller.text});
      snapshot = await mainReference.once();
      Map family = snapshot.value['family'];
      family.forEach(updateVerified);
    } catch (e) {}
  }
  return user;
}

void updateVerified(key, value) {
  try {
    print(_controller.text);
    mainReference = FirebaseDatabase.instance.reference().child("users/" + key);
    mainReference.child("/family/").update({_user.displayName: "v"});
  } catch (e) {}
}

setFirstRun() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('firstRun', false);
}

storeInfo() async {
  final storage = new FlutterSecureStorage();
  List<String> uName = _controller.text.split(" ");
  String user = uName[0];
  String pass = _controller2.text;
  storage.write(key: "username", value: user);
  storage.write(key: "password", value: pass);
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
    _handleSignInMain();
    getWeather();
    getEvents();
    new Future.delayed(new Duration(milliseconds: 500), _menu);
  }

  Future _menu() async {
    if (events != null && weather != null && _user != null) {
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
  final DatabaseReference listenerReference =
      FirebaseDatabase.instance.reference().child("users/" + _user.displayName);

  final DatabaseReference beachListener =
      FirebaseDatabase.instance.reference().child("beach status");

  final DatabaseReference weatherListener =
      FirebaseDatabase.instance.reference().child("weather");

  final DatabaseReference weatherClosureListener =
      FirebaseDatabase.instance.reference().child("weatherDelay");

  TabbedAppBarState() {
    listenerReference.onChildChanged.listen(_familyEdited);
    beachListener.onValue.listen(_editBeachStatus);
    weatherListener.onValue.listen(_editWeather);
    weatherClosureListener.onValue.listen(_editWeatherClosure);
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
      print(message);
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
        weather = event.snapshot.value;
        weatherDescription = weather['longDesc'].toString().split(" ");
        weatherDescriptionFixed = "";
        for (final i in weatherDescription) {
          if (weatherDescriptionFixed != "") {
            weatherDescriptionFixed += " ";
          }
          weatherDescriptionFixed += i.substring(0, 1).toUpperCase();
          weatherDescriptionFixed += i.substring(1, i.length);
        }
      });
    } catch (e) {}
  }

  _editWeatherClosure(Event event) {
    try {
      setState(() {
        weatherClosure = event.snapshot.value == "true" ? true : false;
      });
    } catch (e) {}
  }

  _editBeachStatus(Event event) {
    String status;
    try {
      status = event.snapshot.value;
      setState(() {
        beachOpen = status == "open" ? true : false;
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
    return new MaterialApp(
      home: new DefaultTabController(
        length: isManager ? choicesManager.length: choices.length,
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
              tabs: isManager ? choicesManager.map ((Choice choice) {
                return new Tab(
                  text: choice.title,
                  icon: new Icon(choice.icon),
                );
              }).toList() : choices.map ((Choice choice) {
                return new Tab(
                  text: choice.title,
                  icon: new Icon(choice.icon),
                );
              }).toList(),
            ),
          ),
          body: new TabBarView(
            children: isManager ? choicesManager.map ((Choice choice) {
              return new Padding(
                padding: const EdgeInsets.all(16.0),
                child: new ChoiceState(choice: choice),
              );
            }).toList(): choices.map((Choice choice) {
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
    fontSize = (widthApp / 18).round() * 1.0;
    if (choice.title == "Check-In") {
      print(_user.email);
      return new Center(
        child: new QrImage(version: 2, data: _user.email, size: widthApp / 2),
      );
    } else if (choice.title == "Weather") {
      if (weather == null) {
        return new ListView(children: <Widget>[
          new Container(
            padding: const EdgeInsets.symmetric(horizontal: 125.0),
            child: new RaisedButton(
                onPressed: () async {
                  //weather = await email.getWeather();
                },
                child: new Text('Reload')),
          )
        ]);
      } else {
        String weatherImg;
        Color barColor;
        String alertText;
        if (beachOpen && !weatherClosure) {
          barColor = Colors.green;
          alertText = "Open";
        } else if (!beachOpen && !weatherClosure) {
          barColor = Colors.blueAccent;
          alertText = "Closed - Off Hours";
        } else {
          barColor = Colors.red;
          alertText = "Closed - Inclement Weather";
        }

        switch (weather['icon'].toString()) {
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
            weatherImg = "assets/png/" + weather['icon'].toString() + ".png";
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
                  child: new Text(weatherDescriptionFixed,
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                          fontSize: fontSize, fontFamily: "Raleway"))),
              new Container(
                padding: new EdgeInsets.only(top: heightApp / 25.0),
                alignment: Alignment.center,
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                        child: new Center(
                            child: new Text(
                      "Temp:\n" +
                          weather['temp'].round().toString() +
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
                        "Wind:\n" + weather['wind'].round().toString() + " mph",
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
        // with winds of " + weather[3].round().toString() + " mph. " + "\u000a\u000a
      }
    } else if (choice.title == "Events") {
      int month = new DateTime.now().month;
      int day = new DateTime.now().day;
      List<int> current = new List();
      for (final i in events) {
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
            title: favorites
                ? new Text(
                    (current.length - _saved.length).toString() +
                        " events hidden",
                    style: new TextStyle(color: Colors.black),
                  )
                : new Text(""),
            actions: <Widget>[
              new DropdownButton(
                  hint: favorites
                      ? new Text("Favorites Only")
                      : showCurrent
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
                        _toggleFavorite(false);
                        favorites = false;
                        showCurrent = false;
                      } else if (v == "Favorites Only") {
                        _toggleFavorite(true);
                        favorites = true;
                        showCurrent = true;
                      } else {
                        _toggleFavorite(false);
                        favorites = false;
                        showCurrent = true;
                      }
                    });
                  }),
            ]),
        body: new ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return new GestureDetector(
                onLongPress: () {
                  setState(() {
                    if (_saved.contains((events[index]['eventNum']))) {
                      _saved.remove(events[index]['eventNum']);
                      _handleEvent(
                          events[index]['eventNum'],
                          'remove',
                          events[index]['eventDate'],
                          events[index]['eventName']);
                    } else {
                      _saved.add(events[index]['eventNum']);
                      _handleEvent(
                          events[index]['eventNum'],
                          'add',
                          events[index]['eventDate'],
                          events[index]['eventName']);
                    }
                  });
                },
                child: showCurrent
                    ? current.contains(events[index]['eventNum'])
                        ? !favorites
                            ? new Card(
                                child: new Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    new ExpansionTile(
                                      leading: new Text(
                                          (events[index]['eventDate'])),
                                      title: new Text(
                                        (events[index]['eventName']).toString(),
                                        textAlign: TextAlign.left,
                                      ),
                                      trailing: new Icon(
                                          _saved.contains(
                                                  events[index]['eventNum'])
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: _saved.contains(
                                                  events[index]['eventNum'])
                                              ? Colors.red
                                              : null),
                                      children: <Widget>[
                                        new Container(
                                          padding: new EdgeInsets.only(
                                              left: 16.0,
                                              right: 16.0,
                                              bottom: 16.0),
                                          child: new Text((events[index]
                                              ['eventDescription'])),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : (_saved.contains(events[index]['eventNum'])
                                ? new Card(
                                    child: new Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        new ExpansionTile(
                                          leading: new Text(
                                              (events[index]['eventDate'])),
                                          title: new Text(
                                            (events[index]['eventName'])
                                                .toString(),
                                            textAlign: TextAlign.left,
                                          ),
                                          trailing: new Icon(
                                              _saved.contains(
                                                      events[index]['eventNum'])
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: _saved.contains(
                                                      events[index]['eventNum'])
                                                  ? Colors.red
                                                  : null),
                                          children: <Widget>[
                                            new Container(
                                              padding: new EdgeInsets.only(
                                                  left: 16.0,
                                                  right: 16.0,
                                                  bottom: 16.0),
                                              child: new Text((events[index]
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
                              leading: new Text((events[index]['eventDate'])),
                              title: new Text(
                                (events[index]['eventName']).toString(),
                                textAlign: TextAlign.left,
                              ),
                              trailing: new Icon(
                                  _saved.contains(events[index]['eventNum'])
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      _saved.contains(events[index]['eventNum'])
                                          ? Colors.red
                                          : null),
                              children: <Widget>[
                                new Container(
                                  padding: new EdgeInsets.only(
                                      left: 16.0, right: 16.0, bottom: 16.0),
                                  child: new Text(
                                      (events[index]['eventDescription'])),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ));
          },
          itemCount: events.length,
          //new EventsPage(),
        ),
      );
    } else if (choice.title == 'Profile') {
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
                  new Text(_user.displayName,
                      style: new TextStyle(
                          fontFamily: 'Roboto', fontSize: fontSize)),
                  new Text(userSnapshot.value['email'],
                      style: new TextStyle(
                          fontFamily: 'Roboto', fontSize: fontSize * .75)),
                  new Text(userSnapshot.value['type'] + " Membership",
                      style: new TextStyle(
                          fontFamily: 'Roboto', fontSize: fontSize * .75)),
                  new Text(
                      "Guest Badges - " +
                          userSnapshot.value['guests'].toString(),
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
                  onPressed: () {
                    _signOut();
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
                    style: new TextStyle(
                        fontFamily: 'Roboto',
                        color: Colors.lightBlue,
                        fontSize: 20.0),
                    textAlign: TextAlign.center,
                  )))
        ],
      );
    }
    else if(choice.title == "Manager")
      {
        return new Column(
            children: <Widget>[
            new RaisedButton(onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) => new AlertDialog(
                  title: weatherClosure ? new Text("Open the Beach?") : new Text("Close the Beach?"),
                  content: weatherClosure ? new Text("Are you sure you want to open the beach?") : new Text(
                      'Are you sure you want to close the beach?'),
                  actions: <Widget>[
                    new FlatButton(onPressed: () async{
                      await _closeBeach();
                      Navigator.pop(context);
                    }, child: new Text("Confirm"))
                  ],
                ),
              );

              }, child: weatherClosure ? new Text("Open Beach") : new Text("Close Beach"))],
        );
      }
    else {
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
            padding: new EdgeInsets.only(left: 5.0, top: 5.0),
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
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) =>
                                  new AlertDialog(
                                      title: new Text("Please Enter " +
                                          family[index].name +
                                          "'s Email Address"),
                                      content: new TextField(
                                        controller: _controller,
                                        decoration: new InputDecoration(
                                          hintText: 'example@example.com',
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      actions: <Widget>[
                                        new FlatButton(
                                            child: new Text('Invite'),
                                            onPressed: () async {
                                              await _createUser(
                                                      _controller, index)
                                                  .then((FirebaseUser user) {
                                                if (user != null) {
                                                  Navigator
                                                      .of(context,
                                                      rootNavigator:
                                                      true)
                                                      .pop();
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (BuildContext
                                                            context) =>
                                                        new AlertDialog(
                                                            title: new Text(
                                                                "Success!"),
                                                            content: new Text(
                                                                family[index]
                                                                        .name +
                                                                    " has been invited."),
                                                            actions: <Widget>[
                                                              new FlatButton(
                                                                  child: new Text(
                                                                      'Okay'),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator
                                                                        .of(context,
                                                                            rootNavigator:
                                                                                true)
                                                                        .pop();
                                                                    //Navigator.of(context).pop();
                                                                  })
                                                            ]),
                                                  );

                                                  //Navigator.of(context).pop("good");
                                                } else {

                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (BuildContext
                                                            context) =>
                                                        new AlertDialog(
                                                            title: new Text(
                                                                'User Not Added'),
                                                            content: new Text(
                                                                'Failed to Add User'),
                                                            actions: <Widget>[
                                                              new FlatButton(
                                                                  child: new Text(
                                                                      'Try Again'),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator
                                                                        .of(context,
                                                                            rootNavigator:
                                                                                true)
                                                                        .pop();
                                                                  })
                                                            ]),
                                                  );
                                                }
                                              });
                                            })
                                      ]),
                            );
                            /*Navigator.of(context).push(new MaterialPageRoute(
                      builder: (BuildContext context) {
                        return new InviteUserDialog(index: index);
                      },
                    ));*/
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
                              builder: (BuildContext context) =>
                                  new AlertDialog(
                                      title: new Text("Uninvite"),
                                      content: new Text(
                                          "Are you sure you want to uninvite " +
                                              family[index].name +
                                              "?"),
                                      actions: <Widget>[
                                        new FlatButton(
                                            child: new Text('Yes'),
                                            onPressed: () async {
                                              await _deleteUser(index)
                                                  .then((value) {
                                                if (value) {
                                                  Navigator
                                                      .of(context,
                                                          rootNavigator: true)
                                                      .pop();
                                                  showDialog(
                                                      context: context,
                                                      barrierDismissible: true,
                                                      builder: (BuildContext
                                                              context) =>
                                                          new AlertDialog(
                                                              title: new Text(
                                                                  "Success"),
                                                              content: new Text(
                                                                  family[index]
                                                                          .name +
                                                                      " has been successfully uninvited"),
                                                              actions: <Widget>[
                                                                new FlatButton(
                                                                    child: new Text(
                                                                        "Okay"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator
                                                                          .of(context,
                                                                              rootNavigator: true)
                                                                          .pop();
                                                                    })
                                                              ]));
                                                } else {
                                                  Navigator
                                                      .of(context,
                                                          rootNavigator: true)
                                                      .pop();
                                                  showDialog(
                                                      context: context,
                                                      barrierDismissible: true,
                                                      builder: (BuildContext
                                                              context) =>
                                                          new AlertDialog(
                                                              title: new Text(
                                                                  "Failure"),
                                                              content: new Text(
                                                                  family[index]
                                                                          .name +
                                                                      " has not been uninvited"),
                                                              actions: <Widget>[
                                                                new FlatButton(
                                                                    child: new Text(
                                                                        "Okay"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator
                                                                          .of(context,
                                                                              rootNavigator: true)
                                                                          .pop();
                                                                    })
                                                              ]));
                                                }
                                              });
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
  InviteUserDialog({this.index});

  final int index;

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
                              fontFamily: 'Roboto',
                              fontSize: 15.0,
                              color: Colors.lightBlue)),
                      onPressed: () async {
                        //login = new ServerHandle(_controller.text, _controller2.text);
                        await _createUser(_controller, index)
                            .then((FirebaseUser user) {
                          if (user != null) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) =>
                                  new AlertDialog(
                                      title: new Text("Success!"),
                                      content: new Text(family[index].name +
                                          " has been invited."),
                                      actions: <Widget>[
                                        new FlatButton(
                                            child: new Text('Okay'),
                                            onPressed: () {
                                              Navigator
                                                  .of(context,
                                                      rootNavigator: true)
                                                  .pop();
                                              //Navigator.of(context).pop();
                                            })
                                      ]),
                            );

                            //Navigator.of(context).pop("good");
                          } else {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) =>
                                  new AlertDialog(
                                      title: new Text('User Not Added'),
                                      content: new Text('Failed to Add User'),
                                      actions: <Widget>[
                                        new FlatButton(
                                            child: new Text('Try Again'),
                                            onPressed: () {
                                              Navigator
                                                  .of(context,
                                                      rootNavigator: true)
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

//Weather
getWeather() async {
  mainReference = FirebaseDatabase.instance.reference().child("beach status");
  statusSnapshot = await mainReference.once();
  beachOpen = statusSnapshot.value == "open" ? true : false;
  mainReference = FirebaseDatabase.instance.reference().child("weatherDelay");
  statusSnapshot = await mainReference.once();
  print(statusSnapshot.value);
  weatherClosure = statusSnapshot.value.toString() == "true" ? true : false;

  mainReference = FirebaseDatabase.instance.reference().child("weather");
  statusSnapshot = await mainReference.once();
  weather = statusSnapshot.value;
  weatherDescription = weather['longDesc'].toString().split(" ");

  for (final i in weatherDescription) {
    if (weatherDescriptionFixed != "") {
      weatherDescriptionFixed += " ";
    }
    weatherDescriptionFixed += i.substring(0, 1).toUpperCase();
    weatherDescriptionFixed += i.substring(1, i.length);
  }

}

getEvents() async {
  mainReference = FirebaseDatabase.instance.reference().child("events");
  eventSnapshot = await mainReference.once();
  events = eventSnapshot.value;
}

Future _handleSignInMain() async {
  final storage = new FlutterSecureStorage();
  String uName = await storage.read(key: "username");
  String pass = await storage.read(key: "password");
  FirebaseUser user =
      await _auth.signInWithEmailAndPassword(email: uName, password: pass);
  userReference =
      FirebaseDatabase.instance.reference().child("users/" + user.displayName);
  userSnapshot = await userReference.once();
  family.clear();
  familyList = userSnapshot.value['family'];
  isHead = userSnapshot.value['isHead'];
  isManager = userSnapshot.value['isManager'];
  favorites = userSnapshot.value['favorites'] == "true";
  /*UserUpdateInfo uinfo = new UserUpdateInfo();
  uinfo.displayName = user.displayName;
  uinfo.photoUrl = "https://firebasestorage.googleapis.com/v0/b/membership-application-64ff9.appspot.com/o/Sun.png?alt=media&token=3989d90e-30b7-4469-8ca3-59a1186df796";
  await _auth.updateProfile(uinfo);*/
  try {
    imageProvider = new NetworkImage(user.photoUrl);
  } catch (e) {
    imageProvider = new AssetImage("/assets/png/nouser.png");
  }
  if (familyList != null) {
    familyList.forEach(createFamily);
  }
  _user = user;
  String events = userSnapshot.value['events'];
  List<String> temp = events.split("/");
  for (final i in temp) {
    if (i != "") {
      _saved.add(int.parse(i));
    }
  }
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

Future<FirebaseUser> _createUser(
    TextEditingController controller, int index) async {
  SecureString secureString = new SecureString();
  String pass = secureString.generate(length: 64);
  try {
    FirebaseUser newUser = await _auth.createUserWithEmailAndPassword(
        email: controller.text, password: pass);

    newUser = await _auth.signInWithEmailAndPassword(
        email: controller.text, password: pass);
    UserUpdateInfo uinfo = new UserUpdateInfo();
    uinfo.displayName = family[index].name;
    await _auth.updateProfile(uinfo);
    if (newUser != null) {
      await userReference.child("/family/").update({family[index].name: "i"});
      DatabaseReference temp = FirebaseDatabase.instance
          .reference()
          .child("users/" + family[index].name);
      temp.update({'email': controller.text});
    }
    return newUser;
  }
  catch (e) {
  return null;
  }

  }

Future _closeBeach() async{
  var url = 'https://mediahomecraft.ddns.net/node/beachstatus';
  var success = false;
  if(weatherClosure) {
    await http
        .post(url,
        body: {
          "userID": _user.uid,
          "status": "false"
        },
        encoding: Encoding.getByName("utf-8"))
        .then((response) {
      if (response.body.toString() == "Success") {
        success = true;
      }
    });
  }
  else
    {
      await http
        .post(url,
        body: {
          "userID": _user.uid,
          "status": "true"
        },
        encoding: Encoding.getByName("utf-8"))
        .then((response) {
      if (response.body.toString() == "Success") {
        success = true;
      }
    });
    }

  return success;
}

Future _deleteUser(int index) async {
  var url = 'https://mediahomecraft.ddns.net/node';
  var success = false;
  await http
      .post(url,
          body: {
            "remName": family[index].name,
            "sendName": _user.displayName,
            "userID": _user.uid
          },
          encoding: Encoding.getByName("utf-8"))
      .then((response) {
    if (response.body.toString() == "Success") {
      userReference.child("/family/").update({family[index].name: "nv"});
      success = true;
    }
  });
  return success;
}

_handleEvent(int name, String type, String date, String eName) async {
  mainReference =
      FirebaseDatabase.instance.reference().child("users/" + _user.displayName);
  eventSnapshot = await mainReference.once();
  String events = eventSnapshot.value['events'];
  if (type == "add") {
    /*List<String> tempDate = date.split("/");
    //var scheduledNotificationDateTime = new DateTime(new DateTime.now().year, int.parse(tempDate[0]), int.parse(tempDate[1]), 10);
    var scheduledNotificationDateTime = new DateTime.now().add(new Duration(seconds: 5));
    NotificationDetailsAndroid androidPlatformChannelSpecifics = new NotificationDetailsAndroid("com.yourcompany.lakeapp.ANDROID", "ANDROID CHANNEL", "Event Alerts");
    NotificationDetailsIOS iOSPlatformChannelSpecifics = new NotificationDetailsIOS();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await FlutterLocalNotifications.schedule(name, eName, "Reminder $eName is coming up today", scheduledNotificationDateTime, platformChannelSpecifics);*/
    mainReference.update({"events": events + name.toString() + "/"});
  } else {
    //await FlutterLocalNotifications.cancel(name);
    String newEvents = events.replaceAll("/" + name.toString() + "/", "/");
    newEvents = events.replaceAll(name.toString() + "/", "");
    mainReference.update({"events": newEvents});
  }
}

_toggleFavorite(bool f) {
  mainReference =
      FirebaseDatabase.instance.reference().child("users/" + _user.displayName);
  mainReference.update({"favorites": f.toString()});
}

void _signOut() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('firstRun', true);

  final storage = new FlutterSecureStorage();
  storage.delete(key: "username");
  storage.delete(key: "password");

  await _auth.signOut();

  runApp(new MaterialApp(
    home: new FirstScreen(),
    routes: <String, WidgetBuilder>{
      '/screen1': (BuildContext context) => new FirstScreen(),
      '/screen2': (BuildContext context) => new EnterEmail(),
      '/screen3': (BuildContext context) => new Login(),
      '/screen5': (BuildContext context) => new TabbedAppBarMenu(),
      '/screen6': (BuildContext context) => new LoadingState(),
    },
    initialRoute: '/screen1',
  ));
}

