import 'package:firebase_database/firebase_database.dart';

class Weather {
  DatabaseReference mainReference;
  DataSnapshot statusSnapshot;
  bool beachOpen;
  bool weatherClosure;
  Map weather;
  List weatherDescription;
  String weatherDescriptionFixed = "";
  bool finished;

  getWeather() async {
    print("MADE IT");
    mainReference = FirebaseDatabase.instance.reference().child("beach status");
    statusSnapshot = await mainReference.once();
    beachOpen = statusSnapshot.value == "open" ? true : false;
    mainReference = FirebaseDatabase.instance.reference().child("weatherDelay");
    statusSnapshot = await mainReference.once();
    weatherClosure = statusSnapshot.value.toString() == "true" ? true : false;

    mainReference = FirebaseDatabase.instance.reference().child("weather");
    statusSnapshot = await mainReference.once();
    weather = statusSnapshot.value;
    weatherDescription = weather['longDesc'].toString().split(" ");

    for (final i in weatherDescription) {
      if (weatherDescriptionFixed != "") {
        weatherDescriptionFixed += " ";
      }
      weatherDescriptionFixed += i.substring(0, 1).toUpperCase();
      weatherDescriptionFixed += i.substring(1, i.length);
    }
    finished = true;
  }
}