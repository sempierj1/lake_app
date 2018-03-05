import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:async';
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
     await setQR();
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
  void setQR() async
  {
    print("setqr");
    var url1 = 'https://mediahomecraft.ddns.net/lake/testqr.php';
    var uri1 = Uri.parse(url1);
    var request = new MultipartRequest("POST", uri1);
    request.fields['email'] = email;
    StreamedResponse response1 = await request.send();
    await for(var value1 in response1.stream.transform(utf8.decoder))
    {
      print(value1.toString());
      print("IN FOR");
      if(value1.toString() == "saved")
      {
        print("saved");
      }
      else
      {
       print(value1.toString());
      }
    };
    await getQR();
  }
  void getQR() async
  {
    print("getqr");
    http.Response image = await http.get('https://mediahomecraft.ddns.net/lake/qrcodejs/qr/'+email+'.png',);
    _base64 = BASE64.encode(image.bodyBytes);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("qr", _base64);
  }

}
