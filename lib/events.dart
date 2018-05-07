import 'package:firebase_database/firebase_database.dart';
import 'userInfo.dart';

class Events{
  DatabaseReference mainReference;
  DataSnapshot eventSnapshot;
  List events;
  bool showCurrent = true;
  List saved;

  getEvents() async {
    mainReference = FirebaseDatabase.instance.reference().child("events");
    eventSnapshot = await mainReference.once();
    events = eventSnapshot.value;
  }

  handleEvent(int name, String type, String date, String eName, AppUserInfo userInfo) async {
   DatabaseReference mainReference =
        FirebaseDatabase.instance.reference().child("users/" + userInfo.user.uid);
    DataSnapshot eventSnapshot = await mainReference.once();
    String events = eventSnapshot.value['events'];
    if (type == "add") {
      mainReference.update({"events": events + name.toString() + "/"});
    } else {
      String newEvents = events.replaceAll("/" + name.toString() + "/", "/");
      newEvents = events.replaceAll(name.toString() + "/", "");
      mainReference.update({"events": newEvents});
    }
  }


}