import 'package:firebase_database/firebase_database.dart';

class CheckIn {

  DatabaseReference checkInReference;
  DatabaseReference countReference = FirebaseDatabase.instance
      .reference()
      .child("beachCheckIn/" +
          new DateTime.now().year.toString() +
          "/" +
          new DateTime.now().month.toString() +
          "/" +
          new DateTime.now().day.toString());
  DatabaseReference errors =
      FirebaseDatabase.instance.reference().child("errors");

  updateCount(int num, String badge, int hour) async {
    int tempCount = 0;
    int tempHour = hour;
    int secondHour;
    if(tempHour > 12)
      {
        tempHour -= 12;
      }
      secondHour = tempHour + 1;
    if(secondHour > 12)
      {
        secondHour = 1;
      }

    DataSnapshot countSnapShot = await countReference.once();

    try {
      tempCount = countSnapShot
          .value[tempHour.toString() + "-" + secondHour.toString()];
    } catch (e) {
      tempCount = 0;
    }
    if (tempCount == null) {
      tempCount = 0;
    }
    tempCount += num;

    await countReference
        .update({tempHour.toString() + "-" + secondHour.toString(): tempCount});
    int tempRawCount = 0;
    try {
      tempRawCount = (countSnapShot.value['raw']);
    } catch (e) {
      tempRawCount = 0;
    }
    if (tempRawCount == null) {
      tempRawCount = 0;
    }
    tempRawCount += num;
    await countReference.update({'raw': tempRawCount});

    checkInReference = FirebaseDatabase.instance.reference().child(
        "beachCheckIn/" +
            new DateTime.now().year.toString() +
            "/" +
            new DateTime.now().month.toString() +
            "/" +
            new DateTime.now().day.toString() +
            "/" +
            badge +
            "- UNKNOWN");
    checkInReference.update({
      num.toString():
          tempHour.toString() + ":" + new DateTime.now().minute.toString()
    });
  }

  error(String s) {
    errors.update({s: "Not Found"});
  }
}
