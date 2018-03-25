import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'userinfo.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:zoomable_image/zoomable_image.dart';
import 'eventsHandler.dart';
import 'package:http/http.dart' as http;

final TextEditingController _controller = new TextEditingController();
final TextEditingController _controller1 = new TextEditingController();
bool check = false;
EmailHandler email = new EmailHandler();
EventsListHandler eventsListHandler = new EventsListHandler();

List weather = null;
List events = null;
double widthApp;
double heightApp;
double fontSize = 30.0;
String qr = "";
final double devicePixelRatio = ui.window.devicePixelRatio;
//final QRHandler qr = new QRHandler();


class TabbedAppBarMenu extends StatelessWidget  {
  @override
  Widget build(BuildContext context) {

    email.setEmail();
    getQR();
    getWeather();
    getEvents();
    return new MaterialApp(
      home: new DefaultTabController(
        length: choices.length,
        child: new Scaffold(
          appBar: new AppBar(
            title: const Text('Lake Application'),
            bottom: new TabBar(
              isScrollable: true,
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
                child: new ChoiceCard(choice: choice),
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
  const Choice(title: 'Status', icon: Icons.beach_access),
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
  return user;
}

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({ Key key, this.choice }) : super(key: key);

  final Choice choice;


  @override
  Widget build(BuildContext context) {
    widthApp = MediaQuery.of(context).size.width;
    heightApp = MediaQuery.of(context).size.height;
    fontSize = (widthApp / 18).round() * 1.0;
    if (choice.title == 'Profile') {
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
                      runApp(new LoginApp());
                    },
                    child: new Text('Logout'),
                  ),
                ]
            )
        ),
      );
    }
    else if(choice.title == "Check-In")
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
                  runApp(new LakeApp());
                },
                child: new Text('Reload')
            ),
          )]);
        }
        else {
        Uint8List bytes = BASE64.decode(qr);
        Image myQR = new Image.memory(bytes);
        return new Center(
              child: myQR,
        );
      }

    }
    else if(choice.title == "Status") {
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
        String weatherTxt;
        switch(weather[0].toString())
        {
            case "Clouds":
              weatherImg = 'assets/Cloud.png';
              weatherTxt = "It is currently cloudy and ";
              break;

             case "Thunderstorm":
              weatherImg = 'assets/Thunder.png';
              weatherTxt = "It is currently storming and ";
              break;

          case "Drizzle":
            weatherImg = 'assets/Rain.png';
            weatherTxt = "It is currently drizzling and ";
            break;

          case "Rain":
            weatherImg = 'assets/Rain.png';
            weatherTxt = "It is currently raining and ";
            break;

          case "Snow":
            weatherImg = 'assets/Snow.png';
            weatherTxt = "It is currently snowing and ";
            break;

          case "Clear":
            weatherImg = 'assets/Sun.png';
            weatherTxt = "It is currently sunny and ";
            break;

            default:
              weatherImg = "";
              break;
        }

        return new Card(
            color: Colors.white,
              //child: new Container(
              child: new ListView(
                children: [
                  new Image.asset(weatherImg,
                    height:heightApp/3.0,
                    width:widthApp/3.0,
                    fit: BoxFit.contain,
                  ),
                  new Text("\u000a" + weatherTxt + weather[2].round().toString() + "\u00b0" + "F with winds of " + weather[3].round().toString() + " mph. " + "\u000a\u000a" + "The beach is currently"
                      " closed.",
                      style: new TextStyle(fontSize: fontSize),
                      textAlign: TextAlign.center,
                  )
                ]
              )
              );
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
        return new ListView.builder(
            itemBuilder: (BuildContext context, int index) => new ExpansionTile(leading: new Text((events[index]['eventDate']).toString().substring(5,10)),
             title: new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children:[
                       new Text((events[index]['name']).toString(), textAlign: TextAlign.left,),
                       new RichText(
                         text: new TextSpan(text: (events[index]['isCost']).toString(), style: new TextStyle(color: Colors.green)),
                         ),]
                       //new Text("RSVP", style: new TextStyle(color:Colors.red), textAlign: TextAlign.right),

                   ),
              children: <Widget>[
                new Text((events[index]['description'])),
                new Text("\n"),
                new Text("This event is " + (events[index]['price']).toString(), textAlign: TextAlign.left,),
              ],),
            itemCount: events.length,
          //new EventsPage(),

        );
      }
    }
    else
      {
        return new Container(width: 0.0, height: 0.0);
      }
  }
}
getQR()async
{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  qr = prefs.getString('qr');
  if(qr == null)
    {
      qr = "";
    }
}

getWeather()async
{
  weather = await email.getWeather();
}

getEvents()async
{
  events = await eventsListHandler.getEvents();
  for(int i = 0; i < events.length; i++)
    {
      if(events[i]['price'] != '0')
        {

        }
    }

}
