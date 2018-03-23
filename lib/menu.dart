import 'package:flutter/material.dart';
import 'main.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'userinfo.dart';
import 'dart:ui' as ui;
import 'eventsHandler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseUser _user;


bool check = false;
EmailHandler email = new EmailHandler();
EventsListHandler eventsListHandler = new EventsListHandler();
String qr = "";
List weather;
List events;
double widthApp;
double heightApp;
double fontSize = 30.0;
final mainReference = FirebaseDatabase.instance.reference();

final double devicePixelRatio = ui.window.devicePixelRatio;
//final QRHandler qr = new QRHandler();

class LoadingState extends StatefulWidget{

  LoadingState({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Loading createState() => new Loading();
}
class Loading extends State<LoadingState> {

  Loading(){
    mainReference.onValue.listen(_firstGrab);
  }
  _firstGrab(Event event)
  {
    print(event.snapshot);
  }

  
 void initState()
  {
      _handleSignIn();
      email.setEmail();
      getWeather();
      getEvents();
      new Future.delayed(new Duration(milliseconds: 500), _menu);
  }

  Future _menu() async{
   if(qr != null && events != null && weather != null) {
     Navigator.popAndPushNamed(context, "/screen1");
   }
   else
     new Future.delayed(new Duration(seconds: 1), _menu);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold( // 1
      appBar: new AppBar( //2
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
                    borderRadius: new BorderRadius.circular(10.0)
                ),
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
                          style: new TextStyle(
                              color: Colors.lightBlue
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),);
  }
}

/*lass MenuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new TabbedAppBarMenu();
  }
}*/

class TabbedAppBarMenu extends StatelessWidget  {

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
            title: new Text('Lake Parsippany', textAlign: TextAlign.center, style: new TextStyle(fontFamily: "Roboto"),),
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
  const Choice({ this.title, this.icon });
  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  //const Choice(title: 'Login', icon: Icons.account_circle),
  const Choice(title: 'Check-In', icon: Icons.contacts),
  const Choice(title: 'Weather', icon: Icons.beach_access),
  const Choice(title: 'Events', icon: Icons.event),
  const Choice(title: 'Profile', icon: Icons.account_circle),
  //const Choice(title: 'Calendar', icon: Icons.calendar_today),
  //const Choice(title: 'Check-In', icon: Icons.directions_bus),
  //const Choice(title: 'TRAIN', icon: Icons.directions_railway),
  //const Choice(title: 'WALK', icon: Icons.directions_walk),
];

void deleteCred() async
{
  final storage = new FlutterSecureStorage();
  await storage.delete(key: "username");
  await storage.delete(key: "password");
  await storage.delete(key: "qr");
}
Future<String> getInfo() async
{
  final storage = new FlutterSecureStorage();
  String user = await storage.read(key: "username");
  qr = user;
  return user;
}
class ChoiceState extends StatefulWidget{
  ChoiceState({Key key, this.choice});
  final Choice choice;

  @override
  createState() => new ChoiceCard(choice: choice);
}

class ChoiceCard extends State<ChoiceState> {
  ChoiceCard({ Key key, this.choice });

  final Choice choice;
  final _saved = new Set<String>();



  @override
  Widget build(BuildContext context) {
    widthApp = MediaQuery.of(context).size.width;
    heightApp = MediaQuery.of(context).size.height;
    fontSize = (widthApp / 18).round() * 1.0;
    if(choice.title == "Check-In")
    {
      if(qr == "")
        {
          return new ListView(
           children: <Widget>[
            new Container(
            padding: const EdgeInsets.symmetric(horizontal: 125.0),
            child: new RaisedButton(
                onPressed: ()
                {
                  runApp(new MenuApp());
                },
                child: new Text('Reload')
            ),
          )]);
        }
        else {
        return new Center(
              child: new QrImage(data: qr, size: widthApp / 2),
        );
      }

    }
    else if(choice.title == "Weather") {
      if (weather == null) {
        return new ListView(
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.symmetric(horizontal: 125.0),
                child: new RaisedButton(
                    onPressed: () async{
                      weather = await email.getWeather();
                    },
                    child: new Text('Reload')
                ),
              )
            ]);
      }
      else {
        String weatherImg;
        Color barColor;
        String alertText;
        //CHECK SERVER FOR BEACH STATUS OR ON PULL WITH WEATHER
        bool open = true;
        if(open)
          {
            barColor = Colors.green;
            alertText = "Open";
          }
        else
          {
            barColor = Colors.red;
            alertText = "Closed";
          }

        switch(weather[0].toString())
        {
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
              child: new ListView(
                children: [
                      new Container(
                         width: widthApp,
                         height: 45.0,
                         color: barColor,
                         child: new Center(
                             child: new Text(alertText, textAlign: TextAlign.center, style: new TextStyle(fontSize: fontSize, fontFamily: "Alert")),),
                  ),
                  new Image.asset(weatherImg,
                    height:heightApp/3.0,
                    width:widthApp/3.0,
                    fit: BoxFit.contain,
                  ),
                  new Container(
                    padding: new EdgeInsets.only(top: heightApp/20.0),
                    alignment: Alignment.center,
                    child: new Row(
                    children: <Widget>[
                      new Expanded(
                        child: new Center(
                          child: new Text("Temp:\n" + weather[2].round().toString() + "\u00b0" + "F",
                            style: new TextStyle(fontSize: 45.0, fontFamily: "Raleway"),
                            textAlign: TextAlign.center,
                          )
                        )
                      ),
                      new Expanded(
                      child: new Center(
                        child: new Text("Wind:\n" + weather[3].round().toString() + " mph",
                          style: new TextStyle(fontSize: 45.0, fontFamily: "Raleway"),
                          textAlign: TextAlign.center,
                      )
                      ),)
                    ],
                  ),),

                ]
              )
              );
        // with winds of " + weather[3].round().toString() + " mph. " + "\u000a\u000a
      }
    }
    else if(choice.title == "Events") {
      if (events == null) {
        return new ListView(
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.symmetric(horizontal: 125.0),
                child: new RaisedButton(
                    onPressed: () async {
                      events = await eventsListHandler.getEvents();
                    },
                    child: new Text('Reload')
                ),
              )
            ]);
      }
      else {
        //MAYBE USE CARDS? CHECK EXAMPLE

        return new ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return new GestureDetector(
                onLongPress: () {
                  setState(() {
                    if (_saved.contains((events[index]['name']))) {
                      _saved.remove(events[index]['name']);
                      print("Remove");
                    }
                    else {
                      _saved.add(events[index]['name']);
                      print("Add");
                    }
                  });
                },
                child:
                new Card(
                child: new Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new ExpansionTile(
                    leading: new Text((events[index]['eventDate']).toString().substring(5,10)),
                    title: new Text((events[index]['name']).toString(), textAlign: TextAlign.left,),
                    trailing: new Icon(_saved.contains(events[index]['name']) ? Icons.favorite : Icons.favorite_border,
                    color: _saved.contains(events[index]['name']) ? Colors.red : null),
                      children: <Widget>[
                        new Container(
                        padding: new EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                        child: new Text((events[index]['description'])),
              ),

                      ],
              ),],),),);},
                      /*new ListTile(
                        leading: new Text((events[index]['eventDate']).toString().substring(5,10)),
                        title: new Text((events[index]['name']).toString(), textAlign: TextAlign.left,),
                        subtitle:  new Text((events[index]['price']).toString() + "\n\n", textAlign: TextAlign.center,),
                        trailing:  new Icon(_saved.contains(events[index]['name']) ? Icons.favorite : Icons.favorite_border,
                            color: _saved.contains(events[index]['name']) ? Colors.red : null),

                      ),

                      new Text((events[index]['description'])),

                    ],)
                  //new Text("RSVP", style: new TextStyle(color:Colors.red), textAlign: TextAlign.right),

                );
            }, => new ExpansionTile(leading:  new Icon(_saved.contains(events[index]['name']) ? Icons.favorite : Icons.favorite_border,
                  color: _saved.contains(events[index]['name']) ? Colors.red : null),
                title: new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:[
                      new Text((events[index]['eventDate']).toString().substring(5,10)),
                      new Text((events[index]['name']).toString(), textAlign: TextAlign.left,),
                      new RichText(
                        text: new TextSpan(text: (events[index]['isCost']).toString(), style: new TextStyle(color: Colors.green)),
                      ),]
                  //new Text("RSVP", style: new TextStyle(color:Colors.red), textAlign: TextAlign.right),

                ),

                /*children: <TextSpan>[
                   new TextSpan(),
                   new TextSpan(text:("\$" + (events[index]['price']).toString()), style: new TextStyle(color: Colors.green)),
                   new TextSpan(text: "RSVP", style: new TextStyle(color:Colors.red)),
                   new TextSpan(text:((events[index]['description']))),
*/
                children: <Widget>[
                  new Text((events[index]['description'])),
                  new Text("\n"),
                  new Text("This event is " + (events[index]['price']).toString() + "\n\n", textAlign: TextAlign.left,),
                ],)
            },*/
            itemCount: events.length,
          //new EventsPage(),

        );
      }
    }
    else if(choice.title == 'Profile') {
      return new Card(
        color: Colors.white,
        child: new Center(
            child: new ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: <Widget>[
                  new Text(
                    email.getEmail(),
                  ),
                  new RaisedButton(
                    onPressed: () async
                    {
                      deleteCred();
                      //runApp(new LoginApp());
                    },
                    child: new Text('Logout'),
                  ),
                ]
            )
        ),
      );
    }
    else
      {
        return new Container(width: 0.0, height: 0.0);
      }
  }
}

getWeather()async
{
  weather = await email.getWeather();
}

getEvents()async
{
  events = await eventsListHandler.getEvents();
}

Future _handleSignIn() async {
  final storage = new FlutterSecureStorage();
  String uName = await storage.read(key: "username");
  String pass = await storage.read(key:"password");
  FirebaseUser user = await _auth.signInWithEmailAndPassword(
    email: uName,
    password: pass
  );
  print(mainReference.equalTo(user.uid));
  return user;
}
/*
class EventsPage extends StatefulWidget {
  EventsPageState createState() => new EventsPageState();
}

class EventsPageState extends State<EventsPage> {
  Future<http.Response> _response;

  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _response = http.get(
          'mediahomecraft.ddns.net/lake/getEvents.php'
      );
    });
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Events"),
      ),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.refresh),
        onPressed: _refresh,
      ),
      body: new Center(
          child: new FutureBuilder(
              future: _response,
              builder: (BuildContext context, AsyncSnapshot<http.Response> response) {
                if (!response.hasData)
                  return new Text('Loading...');
                else if (response.data.statusCode != 200) {
                  return new Text('Could not connect to database.');
                } else {
                  Map<String, dynamic> json = JSON.decode(response.data.body);
                  if (json['cod'] == 200) {
                    print("HERE");
                    return new Event(json);
                  }
                  else
                    return new Text('Database service error: $json.');
                }
              }
          )
      ),
    );
  }
}
class Event extends StatelessWidget {
  final Map<String, dynamic> data;
  Event(this.data);
  Widget build(BuildContext context) {
    String name = data[0]['name'];
    return new Text(
        name,
      style: Theme.of(context).textTheme.display4,
    );
  }
}*/
