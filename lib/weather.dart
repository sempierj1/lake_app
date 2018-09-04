import 'package:firebase_database/firebase_database.dart';

class Weather {
  DatabaseReference mainReference;
  DataSnapshot statusSnapshot;
  bool beachOpen;
  bool weatherClosure;
  bool offSeason;
  Map weather;
  List weatherDescription;
  List hours;
  String open;
  String close;
  String openAgain;
  String weatherDescriptionFixed = "";
  bool finished;

  getWeather() async {
    mainReference = FirebaseDatabase.instance.reference().child("beach status");
    statusSnapshot = await mainReference.once();
    beachOpen = statusSnapshot.value == "open" ? true : false;
    mainReference = FirebaseDatabase.instance.reference().child("weatherDelay");
    statusSnapshot = await mainReference.once();
    weatherClosure = statusSnapshot.value.toString() == "true" ? true : false;
    mainReference = FirebaseDatabase.instance.reference().child("offSeason");
    statusSnapshot = await mainReference.once();
    offSeason = statusSnapshot.value.toString() == "true" ? true : false;
    mainReference = FirebaseDatabase.instance.reference().child("weather");
    statusSnapshot = await mainReference.once();
    weather = statusSnapshot.value;
    weatherDescription = weather['longDesc'].toString().split(" ");
    mainReference = FirebaseDatabase.instance.reference().child("hours");
    statusSnapshot = await mainReference.once();
    hours = statusSnapshot.value;

    DateTime d = new DateTime.now();

    close = hours[d.weekday].toString().split("-")[1].substring(0, 2);
    close = (int.parse(close) - 12).toString();
    open = hours[d.weekday].toString().substring(0,2);
    openAgain = hours[d.weekday == 7 ? 1: d.weekday + 1].toString().substring(0,2);

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
