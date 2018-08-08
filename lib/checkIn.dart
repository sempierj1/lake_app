import 'package:firebase_database/firebase_database.dart';

//Class that handles user check in via the sign-in control device
//Handles database updates for user count as users are checked in

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

  /*Gets existing values from Firebase Database and increments them by the number of users
  being checked in.

  @param num, badge, hour

  num - number of people checking in
  badge - badge number of users checking in
  hour - time (hour) of the day the check in is performed
   */
  updateCount(int num, String badge, int hour) async {

    //Gets time frame of check in to use in form of (tempHour-secondHour)
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

    //Attempts to get existing count for current timeframe.
    //If no count is found 0 is used
    //Once a count is set it is incremented by the number of people checking in and updated in the database

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


    //Attempts to get existing count for the day.
    //If no count is found 0 is used
    //Once a count is set it is incremented by the number of people checking in and updated in the database

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
