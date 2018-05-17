import 'package:firebase_database/firebase_database.dart';

class Guest{
  DateTime date = new DateTime.now();
  DatabaseReference mainReference;
  DataSnapshot guestSnapshot;
  int guestNumber = 0;
  int familyNumbers = 0;

  getGuests() async
  {
    mainReference = FirebaseDatabase.instance.reference().child("beachCheckIn/" + date.year.toString() + "/" + date.month.toString() + "/" + date.day.toString());
    guestSnapshot = await mainReference.once();

    Map numGuests = guestSnapshot.value;
    guestNumber =  numGuests.length;

    return numGuests.length;
  }

  getFamily() async
  {
    mainReference = FirebaseDatabase.instance.reference().child("beachCheckIn/" + date.year.toString() + "/" +date.month.toString() + "/" + date.day.toString());
    guestSnapshot = await mainReference.once();
    Map numGuests = guestSnapshot.value;
    List badgeNums = new List();

    sort(String k){
      if(!badgeNums.contains(k.split("-")[0]))
        {
          badgeNums.add(k.split("-")[0]);
        }
    }

    numGuests.forEach((k,v)=> sort(k));

    familyNumbers = badgeNums.length;

    return badgeNums.length;
  }

}