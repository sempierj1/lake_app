import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ServerHandle
{
  bool verified = false;
  String email;
  String pass;
  String _base64;
  ServerHandle(String e, String psw)
  {
    if(e.substring(e.length-1,e.length) == " ")
      {
        e = e.substring(0, e.length-1);
      }
    email = e;
    pass = psw;
  }

  checkLogin()async
  {
    var url = 'https://mediahomecraft.ddns.net/lake/login.php';
    var uri = Uri.parse(url);

    var request = new MultipartRequest("POST", uri);
    request.fields['email'] = email;
    request.fields['password'] = pass;
    StreamedResponse response = await request.send();
    await for(var value in response.stream.transform(utf8.decoder))
    {
    if (value.toString() == "VALID")  {
     await getQR();
    verified = true;
    }
    else {
    verified = false;
    }
    };
  }
  bool getVerified()
  {
    return verified;
  }

  void getQR() async
  {
    var url1 = 'https://mediahomecraft.ddns.net/lake/getQR.php';
    var uri1 = Uri.parse(url1);
    var request = new MultipartRequest("POST", uri1);
    request.fields['email'] = email;
    StreamedResponse response1 = await request.send();
    await for(var value1 in response1.stream.transform(utf8.decoder)) {
      _base64 = value1.toString();
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("qr", _base64);
  }



}
