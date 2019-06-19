import 'package:firebase_database/firebase_database.dart';
import 'userInfo.dart';

//Handles events list for application
//Updates events list as needed based on user input

class Events {
  DatabaseReference mainReference;
  DataSnapshot eventSnapshot;
  List events;
  List eventsShown = new List();
  List general = new List();
  List beach = new List();
  List club = new List();
  List sports = new List();
  List favorites = new List();
  bool showCurrent = true;
  List current = new List();
  final sorting = <String>[
    "General",
    "Beach",
    "Club",
    "Sports",
    "Favorites Only",
    "Show All"
  ];
  String chosen = "General";

  //Gets list of events from the database

  getEvents() async {
    mainReference = FirebaseDatabase.instance.reference().child("events");
    eventSnapshot = await mainReference.once();
    events = eventSnapshot.value;
    eventsShown = events;
    sortEvents();
  }

  //Sorts the events by date and time chronologically
  //Creates a different list based on event type

  sortEvents() {
    int month = new DateTime.now().month;
    int day = new DateTime.now().day;
    for (int i = 0; i < events.length; i++) {
      List tempTime = events[i]['startTime'].split(":");
      if (int.parse(tempTime[0]) > 12) {
        tempTime[0] = (int.parse(tempTime[0]) - 12).toString();
        events[i]['startTime'] = tempTime[0] + ":" + tempTime[1];
        events[i]['time'] = "PM";
      } else {
        events[i]['time'] = "AM";
      }

      if (events[i]['startTime'] == "00:00") {
        events[i]['startTime'] = "";
        events[i]['time'] = "";
      }

      //Adds event to proper list based on tag
      if (int.parse(events[i]['eventDate'].toString().split("-")[0]) > month) {
        current.add(events[i]);
        switch (events[i]['tag']) {
          case "lppoa_event":
            general.add(events[i]);
            break;
          case "club":
            club.add(events[i]);
            break;
          case "beach":
            beach.add(events[i]);
            break;
          case "sports":
            sports.add(events[i]);
            break;
        }
      } else if (int.parse(events[i]['eventDate'].toString().split("-")[0]) ==
              month &&
          int.parse(events[i]['eventDate'].toString().split("-")[1]) >= day) {
        current.add(events[i]);
        switch (events[i]['tag']) {
          case "lppoa_event":
            general.add(events[i]);
            break;
          case "club":
            club.add(events[i]);
            break;
          case "beach":
            beach.add(events[i]);
            break;
          case "sports":
            sports.add(events[i]);
            break;
        }
      }
    }
  }

  //Creates list of saved / favorited events
  getSaved(List saved) {
    if (events != null) {
      for (int i = 0; i < events.length; i++) {
        if (saved.contains(i)) {
          favorites.add(events[i]);
        }
      }
    }
  }

  //Changes events shown based on dropdown input
  setChosen(String v) {
    chosen = v;
    switch (v) {
      case "General":
        eventsShown = general;
        break;
      case "Beach":
        eventsShown = beach;
        break;
      case "Club":
        eventsShown = club;
        break;
      case "Sports":
        eventsShown = sports;
        break;
      case "Favorites Only":
        eventsShown = favorites;
        break;
      case "Show All":
        eventsShown = current;
        break;
    }
  }

  //Adds an event to a users favorite events in the database
  handleEvent(int index, Map event, String type, AppUserInfo userInfo) async {
    DatabaseReference mainReference = FirebaseDatabase.instance
        .reference()
        .child("users/" + userInfo.user.uid);
    DataSnapshot eventSnapshot = await mainReference.once();
    String eventsSnap = eventSnapshot.value['events'];
    if (type == "add") {
      favorites.add(event);
      mainReference
          .update({"events": eventsSnap + event['eventNum'].toString() + "/"});
    } else {
      try {
        favorites.remove(event);
      } catch (e) {
        print("error");
        eventsShown = favorites;
      }
      if (chosen == "Favorites Only") {
        eventsShown = favorites;
      }
      String newEvents =
          eventsSnap.replaceAll("/" + event['eventNum'].toString() + "/", "/");
      newEvents = eventsSnap.replaceAll(event['eventNum'].toString() + "/", "");
      mainReference.update({"events": newEvents});
    }
    favorites.sort((a, b) =>
        int.parse(a['eventDate'].toString().replaceAll("-", "")).compareTo(
            int.parse(b['eventDate'].toString().replaceAll("-", ""))));
  }
}
