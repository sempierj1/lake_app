import 'package:flutter/material.dart';

class MembershipTextStyle {
  TextStyle normalText(BuildContext context) {
    return Theme
        .of(context)
        .textTheme
        .display1
        .copyWith(fontFamily: 'Roboto', fontSize: 20.0);
  }

  TextStyle darkText(BuildContext context) {
    return Theme
        .of(context)
        .textTheme
        .display1
        .copyWith(fontFamily: 'Roboto', fontSize: 20.0, color: Colors.black);
  }

  TextStyle eventText(BuildContext context) {
    return Theme
        .of(context)
        .textTheme
        .display1
        .copyWith(fontFamily: 'Roboto', fontSize: 18.0, color: Colors.black);
  }

  TextStyle eventTextSub(BuildContext context) {
    return Theme
        .of(context)
        .textTheme
        .display1
        .copyWith(fontFamily: 'Roboto', fontSize: 13.0, color: Colors.grey);
  }

  TextStyle whiteText(BuildContext context) {
    return Theme
        .of(context)
        .textTheme
        .display1
        .copyWith(fontFamily: 'Roboto', fontSize: 20.0, color: Colors.white);
  }

  TextStyle header(BuildContext context) {
    return Theme
        .of(context)
        .textTheme
        .display1
        .copyWith(fontFamily: 'Raleway', fontSize: 30.0, color: Colors.black);
  }

  TextStyle banner(BuildContext context) {
    return Theme.of(context).textTheme.display1.copyWith(
        fontFamily: 'Roboto', color: Colors.lightBlue, fontSize: 25.0);
  }

  TextStyle smallFlatButton(BuildContext context) {
    return Theme.of(context).textTheme.display1.copyWith(
        fontFamily: 'Roboto', color: Colors.lightBlue, fontSize: 20.0);
  }

  TextStyle smallerFlatButton(BuildContext context) {
    return Theme.of(context).textTheme.display1.copyWith(
        fontFamily: 'Roboto', color: Colors.lightBlue, fontSize: 15.0);
  }

  TextStyle subText(BuildContext context) {
    return Theme
        .of(context)
        .textTheme
        .display1
        .copyWith(fontFamily: 'Raleway', fontSize: 15.0, color: Colors.grey);
  }

  TextStyle listButtons(BuildContext context) {
    return Theme.of(context).textTheme.display1.copyWith(
        fontFamily: 'Roboto', color: Colors.lightBlue, fontSize: 20.0);
  }

  double fontSize = 30.0;
}
