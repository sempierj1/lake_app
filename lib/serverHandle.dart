import 'dart:convert';
import 'package:http/http.dart';

class ServerHandle
{
  bool verified = false;
  String email;
  String pass;
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

}
