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
import 'guests.dart';
import 'checkInQueue.dart';
import 'queue.dart';

final MembershipTextStyle myStyle = new MembershipTextStyle();
final AppUserInfo userInfo = new AppUserInfo();
final ServerFunctions serverFunctions = new ServerFunctions();
final Events eventHandler = new Events();
final Weather weatherHandler = new Weather();
final Guest guestHandler = new Guest();
final double devicePixelRatio = ui.window.devicePixelRatio;
final TextEditingController _controller = new TextEditingController();
final TextEditingController _controller2 = new TextEditingController();
final Queue queueHandler = new Queue();
/*
  Application to manager LPPOA Membership
  Allows users to:
  Check in to the beach
  Manage their family
  Get notification of beach closures
  See current weather
  View current and upcoming events

  @author Josh Sempier
 */

void main() {
  runCheck();
}

/*
  Checks if there is saved credentials on the system.
  If credentials are saved if will create a MaterialApp and start on the loading screen.
  Otherwise it will take the user to the home page of the application.
 */
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
        //'/screen10': (BuildContext context) => new CheckInQueue(),
        //'/screen11': (BuildContext context) => new LoadingQueueState()
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
        //'/screen10': (BuildContext context) => new CheckInQueue(),
        //'/screen11': (BuildContext context) => new LoadingQueueState()
      },
    ));
  }
}

/*
  Checks if this is the first time running the app.

  @return bool
 */
Future<bool> checkFirstRun() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool run = (prefs.getBool('firstRun') ?? true);
  return run;
}

/*
  Initial screen for the application, presented on initial launch of the application
  
  Offers the user the option to move to the password reset screen for first time users
  or
  The login screen
 */
class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Getting Started", style: myStyle.whiteText(context)),
        ),
        body: new Column(children: <Widget>[
          new Row(
            children: <Widget>[
              new Flexible(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                Navigator.pushNamed(context, "/screen2");
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

/*
  This screen is available after hitting "Get Started" from the initial screen

  The user enters their email and a password reset email is sent to them.

  After acknowledging that the email has been sent they are sent to the login screen.
 */
class EnterEmail extends StatelessWidget {
  /*
    Set the firstRun variable within SharedPreferences to note that the user has used the app.
   */
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
          title: new Text("Enter Email", style: myStyle.whiteText(context)),
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
                          //Send the password Reset email
                          //Create dialog based on success of function
                          await serverFunctions
                              .resetPassword(_controller.text)
                              .then((sent) {
                            if (sent) {
                              setPrefs();
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) =>
                                    new AlertDialog(
                                        title: new Text(
                                            'Password Reset Email Sent'),
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
                                        title: new Text(
                                            'Verification Email Failed'),
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
                          }).catchError((e) {
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
                          });
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

/*
  Login Screen. Users are prompted to enter their email and password to login to the application.

  Sends user to the main page of the application if successful or shows an error message if login is rejected.
 */
class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Enter Email", style: myStyle.whiteText(context)),
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
                          //Attempts to login using the provided credentials, presents error dialog if login fails,
                          //Otherwise pushes the main screen of the application
                          await userInfo
                              .handleSignIn(_controller.text, _controller2.text)
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

/*
  Handles the collection of the various information to be displayed in the main screen and shows a loading screen until collection is complete.
  If collection takes longer than 10s it will prompt the user to login again to prevent an endless load time
 */

class LoadingState extends StatefulWidget {
  LoadingState({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Loading createState() => new Loading();
}

class Loading extends State<LoadingState> {
  Loading();

  int count = 0;

  //Retrieve information needed from various classes
  @override
  void initState() {
    super.initState();
    userInfo.handleSignInMain();
    weatherHandler.getWeather();
    eventHandler.getEvents();
    guestHandler.getGuests();
    guestHandler.getFamily();
    new Future.delayed(new Duration(milliseconds: 500), _menu);
  }

  /*Checks if information collection is complete, if it is, it will push the main screen of the application, otherwise it will wait 1 second and check again
    If 10 seconds pass and information collection is not finished it will prompt the user to login again.
    Collection generally takes between 2 and 5 seconds to complete, depending on connection speed.
   */
  Future _menu() async {
    if ((eventHandler.events != null &&
            weatherHandler.finished != null &&
            userInfo.user != null &&
            userInfo.imageProvider != null) ||
        (userInfo.isBeach)) {
      eventHandler.getSaved(userInfo.saved);
      Navigator.pushReplacementNamed(context, "/screen5");
    } else {
      count++;
      print(count);
      if (count > 10) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => new AlertDialog(
                title: Text("Login Failed"),
                content: Text("Login Failed - Try Again"),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.popAndPushNamed(context, "/screen3");
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

/*
  Main page of the application

  State based tabbed bar menu that switches between the following:

  Check-In - Presents the user with a QR Code that can be scanned to check in.
  Also shows the users badge number which can also be used to check in.

  Weather - Shows the user the beach status (Open, Closed-Off Hours, Closed-Inclement Weather
  as well as the current weather, temperature and wind speed

  Events - Shows the user a list of current and upcoming events.
  User can change sorting via dropdown menu and can favorite events by touching them.

  Profile - User can see their profile picture as well as information about their membership.
  Users can invite their family members to use the application. User's can sign-out from this page.

  Manager - Seen only by users with manager credentials. Shows the user information on people currently at the beach.
  Allows the manager to close the beach and send a notification about the closure.


  If the user logging in is the service account used for checkin the only screen shown is the Sign-In screen which has a camera icon button
  as well as a badge number icon button. The user can choose one of these options to check a person into the beach.
 */
class TabbedAppBarMenu extends StatefulWidget {
  TabbedAppBarMenu({Key key, this.title}) : super(key: key);

  final String title;

  @override
  TabbedAppBarState createState() => new TabbedAppBarState();
}

class TabbedAppBarState extends State<TabbedAppBarMenu>
    with SingleTickerProviderStateMixin {
  /*
  Database listeners are set to update information shown on the various tabs in real time.
   */

  DateTime date = new DateTime.now();
  final DatabaseReference listenerReference = userInfo.isBeach
      ? null
      : FirebaseDatabase.instance
          .reference()
          .child("users/" + userInfo.user.uid);

  final DatabaseReference beachListener = userInfo.isBeach
      ? null
      : FirebaseDatabase.instance.reference().child("beach status");

  final DatabaseReference weatherListener = userInfo.isBeach
      ? null
      : FirebaseDatabase.instance.reference().child("weather");

  final DatabaseReference weatherClosureListener = userInfo.isBeach
      ? null
      : FirebaseDatabase.instance.reference().child("weatherDelay");

  final DatabaseReference guestListener = userInfo.isBeach
      ? null
      : FirebaseDatabase.instance.reference().child("beachCheckIn/" +
          new DateTime.now().year.toString() +
          "/" +
          new DateTime.now().month.toString() +
          "/" +
          new DateTime.now().day.toString());

  final DatabaseReference queueListener = userInfo.isBeach
      ? FirebaseDatabase.instance.reference().child("queue/")
      : null;

  Map familyChanges;

  TabbedAppBarState() {
    if (!userInfo.isBeach) {
      listenerReference.onChildChanged.listen(_familyEdited);
      beachListener.onValue.listen(_editBeachStatus);
      weatherListener.onValue.listen(_editWeather);
      weatherClosureListener.onValue.listen(_editWeatherClosure);
      guestListener.onChildAdded.listen(_guestsEdited);
    }
    else
      {
        queueListener.onChildAdded.listen(_queueEdited);
      }
  }

  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  /*
    During initialization notification permissions are requested and a topic subscription is made.
   */
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
    _firebaseMessaging.configure(
        onLaunch: (Map<String, dynamic> message) {},
        onResume: (Map<String, dynamic> message) {},
        onMessage: (Map<String, dynamic> message) {
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

  int changeCheck = 0;

  /*
    When a new person checks in at the beach this method will be triggered by an update to the database
    This will update the information shown on the manager tab of the application
   */
  _guestsEdited(Event event) {
    if (!userInfo.isBeach) {
      setState(() {
        guestHandler.getGuests();
        guestHandler.getFamily();
      });
    }
  }

  _queueEdited(Event event) {
   setState(() {
       queueHandler.queue.addAll(event.snapshot.value);
      });

  }

  /*
    When a change is made to the weather section of the database this method is called and updates the weather
    page of the tab menu
   */
  _editWeather(Event event) {
    try {
      setState(() {
        weatherHandler.weather = event.snapshot.value;
        weatherHandler.weatherDescription =
            weatherHandler.weather['longDesc'].toString().split(" ");
        weatherHandler.weatherDescriptionFixed = "";
        for (final i in weatherHandler.weatherDescription) {
          if (weatherHandler.weatherDescriptionFixed != "") {
            weatherHandler.weatherDescriptionFixed += " ";
          }
          weatherHandler.weatherDescriptionFixed +=
              i.substring(0, 1).toUpperCase();
          weatherHandler.weatherDescriptionFixed += i.substring(1, i.length);
        }
      });
    } catch (e) {}
  }

  //Handles closure events in the database
  _editWeatherClosure(Event event) {
    try {
      setState(() {
        weatherHandler.weatherClosure =
            event.snapshot.value == "true" ? true : false;
      });
    } catch (e) {}
  }

  //If the beach is changed from open to close or vice versa, this method updates the weather page
  _editBeachStatus(Event event) {
    String status;
    try {
      status = event.snapshot.value;
      setState(() {
        weatherHandler.beachOpen = status == "open" ? true : false;
      });
    } catch (e) {}
  }

  //If a user invites their family member to use the app this changes their displayed status on the profile page.
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

  /*
    Builds the TabBarMenu. If the user is a manager they will see the manager tab
    If they are the login user for the beach they will only see the Sign-In tab
   */
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new DefaultTabController(
        length: userInfo.isManager == "true"
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
              tabs: userInfo.isManager == "true"
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
            children: userInfo.isManager == "true"
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

//Choice list for standard user
const List<Choice> choices = const <Choice>[
  const Choice(title: 'Check-In', icon: Icons.contacts),
  const Choice(title: 'Weather', icon: Icons.beach_access),
  const Choice(title: 'Events', icon: Icons.event),
  const Choice(title: 'Profile', icon: Icons.account_circle),
];

//Choice list for Manager
const List<Choice> choicesManager = const <Choice>[
  const Choice(title: 'Check-In', icon: Icons.contacts),
  const Choice(title: 'Weather', icon: Icons.beach_access),
  const Choice(title: 'Events', icon: Icons.event),
  const Choice(title: 'Profile', icon: Icons.account_circle),
  const Choice(title: 'Manager', icon: Icons.vpn_key)
];

//Choice list for beach service account
const List<Choice> choicesBeach = const <Choice>[
  const Choice(title: 'Sign-In', icon: Icons.image),
];

//Removes username and password from keystore
void deleteCred() async {
  final storage = new FlutterSecureStorage();
  await storage.delete(key: "username");
  await storage.delete(key: "password");
}

//Retrieves the username from keystore
Future<String> getInfo() async {
  final storage = new FlutterSecureStorage();
  String user = await storage.read(key: "username");
  return user;
}

//Displays tabs based on Choice
class ChoiceState extends StatefulWidget {
  ChoiceState({Key key, this.choice});

  final Choice choice;

  @override
  createState() => new ChoiceCard(choice: choice);
}

class ChoiceCard extends State<ChoiceState> {
  ChoiceCard({Key key, this.choice});

  final Choice choice;
  //new QrImage(  version: 3, data: userInfo.user.uid, size: widthApp / 2)
  @override
  Widget build(BuildContext context) {
    //Gets width and height of screen, used for sizing or certain components.
    widthApp = MediaQuery.of(context).size.width;
    heightApp = MediaQuery.of(context).size.height;
    myStyle.fontSize = (widthApp / 18).round() * 1.0;
    switch (choice.title) {
      //Check In Screen. Displays Users badge number and a QR code containing the UID of the user.
      case "Check-In":
        {
          return new SingleChildScrollView(
            padding: EdgeInsets.only(top: heightApp / 6),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: new RaisedButton(child: Text("Check-In"), onPressed: ()async {
                    _controller.clear();
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) => new AlertDialog(
                          title:
                          Text("Number of People"),
                          content: new TextField(
                            controller: _controller,
                            decoration: new InputDecoration(
                              hintText: '# of People',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          actions: <Widget>[
                            FlatButton(
                                onPressed: () async {
                                  await serverFunctions
                                      .checkIn(
                                     userInfo.user, int.parse(_controller.text), DateTime.now().hour, userInfo.badgeNumber)
                                      .then((success) {
                                        print(success);
                                    if (success) {
                                      _controller.clear();
                                      Navigator
                                          .of(context, rootNavigator: true)
                                          .pop();
                                    } else {
                                      Navigator
                                          .of(context, rootNavigator: true)
                                          .pop();
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) =>
                                        new AlertDialog(
                                            title: new Text("Failure!"),
                                            content: new Text(
                                                "Check In Failed, Please Try Again"),
                                            actions: <Widget>[
                                              new FlatButton(
                                                  child:
                                                  new Text('Okay'),
                                                  onPressed: () {
                                                    Navigator
                                                        .of(context,
                                                        rootNavigator:
                                                        true)
                                                        .pop();
                                                    //Navigator.of(context).pop();
                                                  })
                                            ]),
                                      );
                                    }
                                  });
                                },
                                child: Text("Submit"))
                          ],
                        ));
                  })
                ),
                Container(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Center(
                        child: new Text(userInfo.badgeNumber.toString(),
                            style: new TextStyle(
                                fontFamily: "Raleway",
                                fontSize: myStyle.fontSize * 3))))
              ],
            ),
          );
        }
        break;
      //Displays the weather widget. Bar color and message is based on database info on beach
      //Also shows temperature, weather icon and wind speed. Updated every minute from server.
      case "Weather":
        {
          DateTime d = new DateTime.now();
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
              alertText = "Open Until " + weatherHandler.close + "PM";
            } else if (!weatherHandler.beachOpen &&
                !weatherHandler.weatherClosure) {
              barColor = Colors.blueAccent;
              alertText = "Closed Until " + weatherHandler.open + (d.weekday == 7 ? "PM" : "AM");
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

              case "50n":
                weatherImg = 'assets/png/50d.png';
                break;

              default:
                weatherImg = "assets/png/" +
                    weatherHandler.weather['icon'].toString() +
                    ".png";
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
                              fontSize:
                                  widthApp > 700 ? 20.0 : myStyle.fontSize,
                              fontFamily: "Alert")),
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
                              fontSize: myStyle.fontSize,
                              fontFamily: "Raleway"))),
                  new Container(
                    padding: new EdgeInsets.only(top: heightApp / 25.0),
                    alignment: Alignment.center,
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                            child: new Center(
                                child: new Text(
                          "Temp:\n" +
                              weatherHandler.weather['temp']
                                  .round()
                                  .toString() +
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
                            "Wind:\n" +
                                weatherHandler.weather['wind']
                                    .round()
                                    .toString() +
                                " mph",
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
        }
        break;
      //Events Widget. Displays a scrolling list of events from database. Can change events shown via dropdown
      //Can favorite events by tapping on their event card.
      case "Events":
        {
          eventHandler.setChosen(userInfo.favorites);
          List shown = eventHandler.eventsShown;
          return new Scaffold(
            appBar: new AppBar(
                elevation: 0.0,
                backgroundColor: Colors.white,
                title: eventHandler.chosen == "Favorites Only"
                    ? new Text(
                        (eventHandler.events.length - userInfo.saved.length)
                                .toString() +
                            " events hidden",
                        style: new TextStyle(color: Colors.black),
                      )
                    : new Text(""),
                actions: <Widget>[
                  new DropdownButton(
                      hint: new Text(eventHandler.chosen),
                      items: eventHandler.sorting.map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setState(() {
                          userInfo.favorites = v;
                          eventHandler.setChosen(v);
                          userInfo.toggleFavorite(v);
                          shown = eventHandler.eventsShown;
                        });
                      }),
                ]),
            body: new ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return new GestureDetector(
                    onTap: () {
                      if (userInfo.saved.contains(
                          (eventHandler.eventsShown[index]['eventNum']))) {
                        userInfo.saved.remove(
                            eventHandler.eventsShown[index]['eventNum']);
                        eventHandler.handleEvent(
                            index,
                            eventHandler.eventsShown[index],
                            'remove',
                            userInfo);
                      } else {

                        userInfo.saved
                            .add(eventHandler.eventsShown[index]['eventNum']);
                        eventHandler.handleEvent(index,
                            eventHandler.eventsShown[index], 'add', userInfo);
                      }
                      setState(() {
                        if (eventHandler.chosen == "Favorites Only") {
                          shown = eventHandler.favorites;
                        }
                      });
                    },
                    child: Card(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                          new ListTile(
                            leading: new Text((shown[index]['eventDate']),
                                style: new TextStyle(
                                    fontSize: widthApp > 600
                                        ? 12.0
                                        : myStyle.fontSize * (widthApp / 755))),
                            title: new Text(
                              (shown[index]['eventName']).toString(),
                              style: myStyle.eventText(context),
                            ),
                            subtitle: (shown[index]['location'] != "" &&
                                    shown[index]['startTime'] != "")
                                ? Text(
                                    shown[index]['location'] != ""
                                        ? (shown[index]['location'] +
                                            " - " +
                                            shown[index]['startTime'] +
                                            shown[index]['time'])
                                        : "",
                                    style: myStyle.eventTextSub(context),
                                  )
                                : null,
                            trailing: new Icon(
                                userInfo.saved
                                        .contains(shown[index]['eventNum'])
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: userInfo.saved
                                        .contains(shown[index]['eventNum'])
                                    ? Colors.red
                                    : null),
                          ),
                          new ButtonTheme.bar(
                              // make buttons use the appropriate styles for cards
                              child: new ButtonBar(children: <Widget>[
                            FlatButton(
                                onPressed: () {
                                  serverFunctions.launchURL(
                                      shown[index]['url'].toString());
                                },
                                child: new Text(
                                  "More Information",
                                  style: myStyle.smallerFlatButton(context),
                                ))
                          ])),
                        ])));
              },
              itemCount: shown.length,
            ),
          );
        }
        break;
      //Shows the users profile. Will display name, email, membership type
      //Also shows the family widget that allows for inviting family members

      case "Profile":
        {
          List<Widget> children = new List.generate(userInfo.family.length,
              (int i) => new FamilyWidget(i, context, userInfo));
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
                                  title:
                                      new Text("Where's My Profile Picture?"),
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
                      new Text(userInfo.user.displayName ?? "Test User",
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: myStyle.fontSize)),
                      new Text(userInfo.userSnapshot.value['email'],
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: myStyle.fontSize * .5)),
                      new Text(userInfo.userSnapshot.value['type'],
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: myStyle.fontSize * .75)),
                      new Text(
                          "Guest Badges - " +
                              userInfo.userSnapshot.value['guest'].toString(),
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: myStyle.fontSize * .75)),
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
                        _controller.value = new TextEditingValue();
                        _controller2.value = new TextEditingValue();
                        userInfo.signOut();
                        try {
                          Navigator
                              .of(context, rootNavigator: true)
                              .pop(context);
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
        }
        break;
      //Manager view. Displays information on beach use for the day.
      //Allows the manager to close the beach via button push.
      case "Manager":
        {
          return ListView(
              children: <Widget>[ Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: new Text(
                        guestHandler.guestNumber.toString() + "\n People Today",
                        style: new TextStyle(
                            fontFamily: "Raleway",
                            fontSize: 11.25 * (heightApp / 200)),
                        textAlign: TextAlign.center),
                  ),
                  Expanded(
                    child: new Text(
                        guestHandler.familyNumbers.toString() +
                            "\n Families Today",
                        style: new TextStyle(
                            fontFamily: "Raleway",
                            fontSize: 11.25 * (heightApp / 200)),
                        textAlign: TextAlign.center),
                  )
                ],
              ),
              Row(children: <Widget>[
                Expanded(
                    child: IconButton(
                      iconSize: 100.0,
                  icon: Icon(Icons.account_circle),
                  onPressed: () async {
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) => new AlertDialog(
                              title:
                                  Text("Enter WildApricot Contact Number"),
                              content: new TextField(
                                controller: _controller,
                                decoration: new InputDecoration(
                                  hintText: '12345678',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              actions: <Widget>[
                                FlatButton(
                                    onPressed: () async {
                                      await serverFunctions
                                          .updateMember(
                                              _controller.text)
                                          .then((success) {
                                        if (success) {
                                          Navigator
                                              .of(context, rootNavigator: true)
                                              .pop();
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) =>
                                                new AlertDialog(
                                                    title: new Text("Success!"),
                                                    content: new Text(
                                                        "User updated"),
                                                    actions: <Widget>[
                                                      new FlatButton(
                                                          child:
                                                              new Text('Okay'),
                                                          onPressed: () {
                                                            Navigator
                                                                .of(context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                            //Navigator.of(context).pop();
                                                          })
                                                    ]),
                                          );
                                        } else {
                                          Navigator
                                              .of(context, rootNavigator: true)
                                              .pop();
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) =>
                                                new AlertDialog(
                                                    title: new Text("Failure!"),
                                                    content: new Text(
                                                        "User has not been updated"),
                                                    actions: <Widget>[
                                                      new FlatButton(
                                                          child:
                                                              new Text('Okay'),
                                                          onPressed: () {
                                                            Navigator
                                                                .of(context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                            //Navigator.of(context).pop();
                                                          })
                                                    ]),
                                          );
                                        }
                                      });
                                    },
                                    child: Text("Submit"))
                              ],
                            ));
                  },
                ))
              ]),
              new Align(
                heightFactor: 3.2,
                child: FlatButton(
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
                                      showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) =>
                                              new AlertDialog(
                                                title:
                                                    new Text("Sending Message"),
                                                content: new Container(
                                                  height: 200.0,
                                                  child: new Center(
                                                    child: new SizedBox(
                                                      height: 50.0,
                                                      width: 50.0,
                                                      child:
                                                          new CircularProgressIndicator(
                                                        value: null,
                                                        strokeWidth: 7.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ));
                                      await serverFunctions.closeBeach(
                                          weatherHandler.weatherClosure);
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: new Text("Confirm"))
                              ],
                            ),
                      );
                    },
                    child: weatherHandler.weatherClosure
                        ? new Text(
                            "Open Beach",
                            style: myStyle.smallFlatButton(context),
                            textAlign: TextAlign.center,
                          )
                        : new Text(
                            "Close Beach",
                            style: myStyle.smallFlatButton(context),
                            textAlign: TextAlign.center,
                          )),
              )
            ],
          ),]);
        }
        break;

      //Sign In view for the app
      //Shows an option to sign in via QR code or badge number.
      case "Sign-In":
        {
          return new Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              new Row(children: <Widget>[
                new Expanded(
                    /*child: new IconButton(
                        icon: new Icon(Icons.camera_alt),
                        iconSize: 70.0,
                        color: Colors.lightBlue,
                        onPressed: () {
                          Navigator
                              .of(context, rootNavigator: true)
                              .pushNamed("/screen8");
                        })),*/
                    child: new IconButton(
                        icon: new Icon(Icons.list),
                        iconSize: 70.0,
                        color: Colors.lightBlue,
                        onPressed: () {
                          Navigator
                              .of(context, rootNavigator: true)
                              .pushNamed("/screen11");
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
                        _controller.value = new TextEditingValue();
                        _controller2.value = new TextEditingValue();
                        userInfo.signOut();
                        try {
                          Navigator
                              .of(context, rootNavigator: true)
                              .pop(context);
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
        }
        break;
      default:
        {
          return new Container(width: 0.0, height: 0.0);
        }
    }
  }
}
