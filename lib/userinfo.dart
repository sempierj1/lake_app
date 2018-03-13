import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_qr/google_qr.dart';

class EmailHandler {
  String email;

  setEmail() async
  {
    final storage = new FlutterSecureStorage();
    email = await storage.read(key: "username");
  }

  getEmail()
  {
    return email;
  }
  Future<List> getWeather()async
  {
    var httpClient = new HttpClient();
    var uri = new Uri.https(
        'mediahomecraft.ddns.net', '/lake/weather.php');
    var request = await httpClient.getUrl(uri);
    var response = await request.close();
    var responseBody = await response.transform(UTF8.decoder).join();
    List data = JSON.decode(responseBody);
    return data;
  }
}



