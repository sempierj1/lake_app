import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'menu.dart';

//test
void main()
{
  runCheck();
}

void runCheck() async{
  bool check = await checkFirstRun();
  bool check2 = await checkInfo();
  if(check)
  {
    runApp(new MyApp());
  }
  else if(!check && !check2)
  {
    runApp(new LoginApp());
  }
  else
  {
    runApp(new LakeApp());
  }
}
Future<bool> checkFirstRun() async
{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool run = (prefs.getBool('firstRun') ?? true);
  return run;
}

Future<bool> checkInfo() async
{
  final storage = new FlutterSecureStorage();
  String user = await (storage.read(key: "username")?? null);
  if (user != null) {
    return true;
  }
  else
  {
    return false;
  }
}
//TEST VARIABLES
bool sent = false;
int message = 0;

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new TabbedAppBarSample();
  }
}

class LakeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new TabbedAppBarMenu();
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
            child: new LogonWidget(),
          )
      ),
    );
  }
}

class LogonWidget extends StatefulWidget
{
  @override
  _LogonWidgetState createState() => new _LogonWidgetState();
}
setPrefs() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('firstRun', true);
}

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
      response.stream.transform(utf8.decoder).listen(((value){
        if(value.toString().length == 1)
          {
            sent = true;
          }
        else
          {
            sent = false;
          }
      }));
    }catch(exception)
    {
      print(exception);
      sent = false;
      //Error Message Here
    }
    return sent;
  }
}


