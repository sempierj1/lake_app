import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final TextEditingController _controller = new TextEditingController();
final TextEditingController _controller1 = new TextEditingController();
bool check = false;

class TabbedAppBarSample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
  const Choice(title: 'Login', icon: Icons.account_circle),
  //const Choice(title: 'BICYCLE', icon: Icons.directions_bike),
  //const Choice(title: 'BOAT', icon: Icons.directions_boat),
  //const Choice(title: 'BUS', icon: Icons.directions_bus),
  //const Choice(title: 'TRAIN', icon: Icons.directions_railway),
  //const Choice(title: 'WALK', icon: Icons.directions_walk),
];

setFirstRun() async
{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('firstRun', false);
}

storeInfo() async
{
  final storage = new FlutterSecureStorage();
  String user = _controller.text;
  String pass = _controller1.text;
  storage.write(key: "username", value: user);
  storage.write(key: "password", value: pass);
}

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({ Key key, this.choice }) : super(key: key);

  final Choice choice;


  @override
  Widget build(BuildContext context) {
    if (choice.title == 'Login') {
      return new Form(

          child: new ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
                new TextFormField(
                  controller: _controller,
                  decoration: new InputDecoration(
                    hintText: 'Email',
                  ),
                ),
                new TextFormField(
                  controller: _controller1,
                  decoration: new InputDecoration(
                    hintText: 'Password',
                  ),
                  obscureText: true,
                ),
                new RaisedButton(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: new Text('Login'),
                    onPressed: () async {
                      await checkForm();
                      print(check);
                      if (check) {
                        await setFirstRun();
                        await storeInfo();
                        runApp(new LakeApp());
                      }
                      else {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          child: new AlertDialog(
                              title: new Text('Login Failed'),
                              content: new Text(
                                  'Please Try Again'),
                              actions: <Widget>[
                                new FlatButton(
                                    child: new Text('Try Again'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }
                                )
                              ]
                          ),
                        );
                      }
                    }
                )
              ]
          )
      );
    }


    final TextStyle textStyle = Theme
        .of(context)
        .textTheme
        .display1;
    return new Card(
      color: Colors.white,
      child: new Center(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Icon(choice.icon, size: 128.0, color: textStyle.color),
            new Text(choice.title, style: textStyle),
          ],
        ),
      ),
    );
  }
}

  Future<bool> checkForm() async
  {
    String email = _controller.text;
    String pass = _controller1.text;

    var url = 'https://mediahomecraft.ddns.net/lake/login.php';
    var uri = Uri.parse(url);
    try 
    {
      var request = new MultipartRequest("POST", uri);
      request.fields['email'] = email;
      request.fields['password'] = pass;
      StreamedResponse response = await request.send();
      response.stream.transform(utf8.decoder).listen(((value) {
        if (value.toString() == "VALID")  {
          print("ONE");
          check = true;
        }
        else {
          print("TWO");
          check = false;
        }
      }));

    }catch(exception)
    {
      print("THREE");
     //Error Message Here

    }
    return check;
  }