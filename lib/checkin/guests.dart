import 'package:firebase_database/firebase_database.dart';

/*Returns information on daily attendance at the beach. Only returns information from the current day. For further information
* please check the associated website
*/
class Guest {
  DateTime date = new DateTime.now();
  DatabaseReference mainReference;
  DataSnapshot guestSnapshot;
  int guestNumber = 0;
  int familyNumbers = 0;

  //Returns total number of guests

  getGuests() async {
    mainReference = FirebaseDatabase.instance.reference().child(
        "beachCheckIn/" +
            date.year.toString() +
            "/" +
            date.month.toString() +
            "/" +
            date.day.toString());
    guestSnapshot = await mainReference.once();
    int numGuests = 0;
    try {
      numGuests = guestSnapshot.value['raw'];
    } catch (e) {
      numGuests = 0;
    }
    guestNumber = numGuests;
    return guestNumber;
  }

  //Returns number of families
  getFamily() async {
    mainReference = FirebaseDatabase.instance.reference().child(
        "beachCheckIn/" +
            date.year.toString() +
            "/" +
            date.month.toString() +
            "/" +
            date.day.toString());
    guestSnapshot = await mainReference.once();
    Map numGuests = guestSnapshot.value;
    int others = 0;
    if (numGuests != null) {
      if (guestSnapshot.value['10-11'] != null) {
        others++;
      }
      if (guestSnapshot.value['11-12'] != null) {
        others++;
      }
      if (guestSnapshot.value['12-1'] != null) {
        others++;
      }
      if (guestSnapshot.value['1-2'] != null) {
        others++;
      }
      if (guestSnapshot.value['2-3'] != null) {
        others++;
      }
      if (guestSnapshot.value['3-4'] != null) {
        others++;
      }
      if (guestSnapshot.value['4-5'] != null) {
        others++;
      }
      if (guestSnapshot.value['5-6'] != null) {
        others++;
      }
      if (guestSnapshot.value['6-7'] != null) {
        others++;
      }
      if (guestSnapshot.value['raw'] != null) {
        others++;
      }
    }
    if (numGuests != null) {
      familyNumbers = numGuests.length - others;
    } else {
      familyNumbers = 0;
    }
    return familyNumbers;
  }
}
