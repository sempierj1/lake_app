import 'package:firebase_database/firebase_database.dart';

/*Handles Check-In Queue
* Queue is a Map of Badge Numbers and User amounts*/

class Queue {
  Map queue = new Map();
  DatabaseReference queueReference =
      FirebaseDatabase.instance.reference().child("queue");
  DataSnapshot queueSnapShot;
  List queueKeys = new List();
  List checked = new List();

  Queue();

  /*Returns the current queue from the database*/
  getQueue() async {
    queueSnapShot = await queueReference.once();
    try {
      queue = queueSnapShot.value;
    } catch (e) {
      print(e);
    }
    if (queue != null) {
      queueKeys = queue.keys.toList();
      for (int i = 0; i < queueKeys.length; i++) {
        checked.add(false);
      }
    }
    //if (queue != null)
    //queueKeys = queue.keys.toList();
  }
}
