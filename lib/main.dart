import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'menu.dart';
import 'serverHandle.dart';

TextEditingController _controller = new TextEditingController();
TextEditingController _controller2 = new TextEditingController();
ServerHandle login;
//test
void main()
{
  
  runCheck();
}

void runCheck() async{
  bool check = await checkFirstRun();
  //bool check2 = await checkInfo();
  if(check)
  {
    runApp(new MaterialApp(
      home: new FirstScreen(),
      routes: <String, WidgetBuilder>{
        '/screen1': (BuildContext context) => new FirstScreen(),
        '/screen2': (BuildContext context) => new EnterEmail(),
        '/screen3': (BuildContext context) => new Login(),
        '/screen4': (BuildContext context) => new LoadScreen(),
      },
    ));
  }
  else
  {
    runApp(new MaterialApp(
      home: new LoadingState(),
      routes: <String, WidgetBuilder>{
        '/screen1': (BuildContext context) => new TabbedAppBarMenu(),
        '/screen2': (BuildContext context) => new LoadingState(),
      },
    ));
  }
}
Future<bool> checkFirstRun() async
{
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
bool sent = false;
int message = 0;

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new TabbedAppBarSample();
  }
}

class MenuApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return new TabbedAppBarMenu();
  }
}

class LakeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new LoadingState();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Lake Parsippany',
      theme: new ThemeData(primaryColor: Colors.lightBlue,),
      home: new Scaffold(
          appBar: new AppBar(
            title: new Text('Registration'),
          ),
          body: new Center(
            //child: new LogonWidget(),
          )
      ),
    );
  }
}

/*class LogonWidget extends StatefulWidget
{
  @override
  //_LogonWidgetState createState() => new _LogonWidgetState();
}*/
setPrefs() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('firstRun', true);
}
/*
class _LogonWidgetState extends State<LogonWidget>
{
  final TextEditingController _controller = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new TextField(
          controller: _controller,
          decoration: new InputDecoration(
            hintText: 'Please enter your email',
          ),
        ),
        new RaisedButton(
          onPressed: () async {
            await sendEmail();
            if(sent) {
              setPrefs();
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  child: new AlertDialog(
                    title: new Text('Verification Email Sent'),
                    content: new Text(
                        'Please Check Your Email For Further Instructions'),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text('Continue'),
                      onPressed:(){
                        runApp(new LoginApp());
                      }
                    )
                  ]
                  ),
              );
            }
            else
              {
                showDialog(
                    context: context,
                    child: new AlertDialog(
                      title: new Text('Verification Email Failed'),
                      )
                );
              }

          },
          child: new Text('Submit'),
        ),
        new RaisedButton(
        onPressed: () {
          runApp(new LoginApp());
        },
        child: new Text('Login'),)
      ],
    );
  }


  Future<bool>sendEmail() async
  {
    var email = _controller.text;
    var url = 'https://mediahomecraft.ddns.net/lake/main.php';
    var uri = Uri.parse(url);
    try
    {
      var request = new MultipartRequest("POST", uri);
      request.fields['email'] = email;
      StreamedResponse response = await request.send();
      await for(var value in response.stream.transform(utf8.decoder))
      {
        if(value.toString().length == 1)
          {
            sent = true;
          }
        else
          {
            sent = false;
          }
      };
    }catch(exception)
    {
      print(exception);
      sent = false;
      //Error Message Here
    }
    return sent;
  }
}*/


class FirstScreen extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return new Scaffold( // 1
      appBar: new AppBar( //2
        title: new Text("Getting Started", style: new TextStyle(fontFamily: 'Roboto', fontSize: 20.0)),

      ),
      body: new ListView(
          children: <Widget>[
            new Row(
            children: <Widget> [
              new Flexible(
                child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                new Text('\n\nWelcome to the Lake Parsippany Phone App',
                    style: new TextStyle(fontFamily: 'Raleway', fontSize: 30.0, color: Colors.black),
                    textAlign: TextAlign.center),
          ],),),],),
          new Align(
            heightFactor: 5.0,
            alignment: Alignment.bottomCenter,
            child: new FlatButton(onPressed:(){ // 4
              Navigator.pushNamed(context, "/screen2");// 5
    } ,     child: new Text("Get Started", style: new TextStyle(fontFamily: 'Roboto', color:Colors.lightBlue, fontSize: 25.0), textAlign: TextAlign.center,),),),

            new Align(
              heightFactor: 5.0,
              alignment: Alignment.bottomCenter,
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                new Text("Used the App Before?", style: new TextStyle(fontFamily: 'Raleway', fontSize: 15.0, color: Colors.grey), textAlign: TextAlign.center,),
                new FlatButton(
                    onPressed:(){ // 4
                      Navigator.pushNamed(context, "/screen3"); // 5
              } ,     child: new Text("Login", style: new TextStyle(fontFamily: 'Roboto', color: Colors.lightBlue, fontSize: 15.0),),),],),),])
    );
  }
}



class EnterEmail extends StatelessWidget {

  setPrefs() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('firstRun', true);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold( // 1
        appBar: new AppBar( //2
          title: new Text("Enter Email", style: new TextStyle(fontFamily: 'Roboto', fontSize: 20.0)),

        ),
        body: new ListView(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0),
            children: <Widget>[
              new Row(
                children: <Widget> [
                  new Flexible(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text('\n\nPlease Enter the Email Associated With Your Membership',
                            style: new TextStyle(fontFamily: 'Raleway', fontSize: 30.0, color: Colors.black),
                            textAlign: TextAlign.center),
                      ],),),],),
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
            onPressed: () async {
              await sendEmail();
              if(sent)
                {
                  setPrefs();
                  Navigator.pushNamed(context, "/screen3");
                }
              else
                {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    child: new AlertDialog(
                        title: new Text('Verification Email Failed'),
                        content: new Text(
                            'Please Be Sure to Enter the Email Associated with Your Membership'),
                        actions: <Widget>[
                          new FlatButton(
                              child: new Text('Try Again'),
                              onPressed:(){
                                Navigator.pop(context);
                              }
                          )
                        ]
                    ),
                  );
                }

    }, child: new Text("Submit", style: new TextStyle(fontFamily: 'Roboto', color:Colors.lightBlue, fontSize: 15.0), textAlign: TextAlign.center,)
    ),),],),])
    );
  }

  Future<bool>sendEmail() async
  {
    var email = _controller.text;
    var url = 'https://mediahomecraft.ddns.net/lake/main.php';
    var uri = Uri.parse(url);
    try
    {
      var request = new MultipartRequest("POST", uri);
      request.fields['email'] = email;
      StreamedResponse response = await request.send();
      await for(var value in response.stream.transform(utf8.decoder))
      {
        if(value.toString().length == 1)
        {
          sent = true;
        }
        else
        {
          sent = false;
        }
      };
    }catch(exception)
    {
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
    return new Scaffold( // 1
        appBar: new AppBar( //2
          title: new Text("Enter Email", style: new TextStyle(fontFamily: 'Roboto', fontSize: 20.0)),

        ),
        body: new ListView(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0),
            children: <Widget>[
              new Row(
                children: <Widget> [
                  new Flexible(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text('\n\nPlease Enter Your Email Address and Password',
                            style: new TextStyle(fontFamily: 'Raleway', fontSize: 30.0, color: Colors.black),
                            textAlign: TextAlign.center),
                      ],),),],),
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
                    ),),
                  new Align(
                    heightFactor: 2.0,
                    alignment: Alignment.bottomCenter,
                    child: new FlatButton(
                        onPressed: () async {
                          login = new ServerHandle(_controller.text, _controller2.text);
                          await login.checkLogin();
                          if (login.getVerified()) {
                            await setFirstRun();
                            await storeInfo();
                            Navigator.pushNamed(context, "/screen4");
                            /*runApp(new MaterialApp(
                              home: new TabbedAppBarMenu(),
                              routes: <String, WidgetBuilder>{
                                '/screen1': (BuildContext context) => new TabbedAppBarMenu(),
                                '/screen2': (BuildContext context) => new LoadingState(),
                              },
                            ));*/
                          }
                          else
                          {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              child: new AlertDialog(
                                  title: new Text('Login Failed'),
                                  content: new Text(
                                      'Login Credentials Are Case Sensitive'),
                                  actions: <Widget>[
                                    new FlatButton(
                                        child: new Text('Try Again'),
                                        onPressed:(){
                                          _controller2.text = "";
                                          Navigator.pop(context);
                                        }
                                    )
                                  ]
                              ),
                            );
                          }

                        }, child: new Text("Submit", style: new TextStyle(fontFamily: 'Roboto', color:Colors.lightBlue, fontSize: 15.0), textAlign: TextAlign.center,)
                    ),),],),])
    );
  }
  setFirstRun() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('firstRun', false);
  }

  storeInfo() async
  {
    final storage = new FlutterSecureStorage();
    String user = _controller.text;
    String pass = _controller2.text;
    storage.write(key: "username", value: user);
    storage.write(key: "password", value: pass);
  }
}


class LoadScreen extends StatefulWidget{

  LoadScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Loading createState() => new Loading();
}
class Loading extends State<LoadScreen> {

  void initState()
  {
    email.setEmail();
    getQR();
    getWeather();
    getEvents();
    new Future.delayed(new Duration(seconds: 5), _menu);
  }

  Future _menu() async{
      runApp(new MenuApp());
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
                          "Finishing a Few Things",
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
