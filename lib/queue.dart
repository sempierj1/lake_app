import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

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