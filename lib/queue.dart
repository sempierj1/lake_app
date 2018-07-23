import 'package:firebase_database/firebase_database.dart';


class Queue{

  Map queue = new Map();
  DatabaseReference queueReference =
  FirebaseDatabase.instance.reference().child("queue");
  DataSnapshot queueSnapShot;
  List queueKeys;

  Queue();

  getQueue() async {
      queueSnapShot = await queueReference.once();
      try {
        queue = queueSnapShot.value;
      }
      catch (e)
    {}
      if (queue != null)
        queueKeys = queue.keys.toList();
  }
}