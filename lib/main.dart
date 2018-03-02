import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'dart:async';

//test
void main()
{
  runCheck();
}

void runCheck() async{
  bool check = await checkFirstRun();
  if(check)
  {
    runApp(new MyApp());
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
//TEST VARIABLES
bool sent = true;
int message = 0;

class LakeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new TabbedAppBarSample();
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
                        runApp(new LakeApp());
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


