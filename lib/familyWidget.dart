import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'membershipTextStyles.dart';
import 'userInfo.dart';
import 'serverFunctions.dart';

class FamilyWidget extends StatelessWidget {
  final int index;
  final AppUserInfo userInfo;
  final MembershipTextStyle myStyle = new MembershipTextStyle();
  final TextEditingController _controller = new TextEditingController();
  final ServerFunctions serverFunctions = new ServerFunctions();

  FamilyWidget(this.index, BuildContext c, this.userInfo);

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Expanded(
          child: new Container(
            padding: new EdgeInsets.only(left: 5.0, top: 5.0),
            child: new Text(userInfo.family[index].name,
                style: myStyle.normalText(context)),
          ),
        ),
        userInfo.isHead == "true"
            ? new Align(
                alignment: Alignment.bottomRight,
                child: userInfo.family[index].invited == "v"
                    ? new Container(
                        padding: const EdgeInsets.only(right: 30.0),
                        child: new Icon(
                          Icons.check,
                          color: Colors.lightBlue,
                        ))
                    : new FlatButton(
                        onPressed: () {
                          if (userInfo.family[index].invited == 'nv') {
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) =>
                                  new AlertDialog(
                                      title: new Text("Please Enter " +
                                          userInfo.family[index].name +
                                          "'s Email Address"),
                                      content: new TextField(
                                        controller: _controller,
                                        decoration: new InputDecoration(
                                          hintText: 'example@example.com',
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      actions: <Widget>[
                                        new FlatButton(
                                            child: new Text('Invite'),
                                            onPressed: () async {
                                              await serverFunctions
                                                  .createUser(_controller,
                                                      index, userInfo.user.uid)
                                                  .then((FirebaseUser user) {
                                                if (user != null) {
                                                  Navigator
                                                      .of(context,
                                                          rootNavigator: true)
                                                      .pop();
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (BuildContext
                                                            context) =>
                                                        new AlertDialog(
                                                            title: new Text(
                                                                "Success!"),
                                                            content: new Text(userInfo
                                                                    .family[
                                                                        index]
                                                                    .name +
                                                                " has been invited."),
                                                            actions: <Widget>[
                                                              new FlatButton(
                                                                  child: new Text(
                                                                      'Okay'),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator
                                                                        .of(context,
                                                                            rootNavigator:
                                                                                true)
                                                                        .pop();
                                                                    //Navigator.of(context).pop();
                                                                  })
                                                            ]),
                                                  );

                                                  //Navigator.of(context).pop("good");
                                                } else {
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (BuildContext
                                                            context) =>
                                                        new AlertDialog(
                                                            title: new Text(
                                                                'User Not Added'),
                                                            content: new Text(
                                                                'Failed to Add User'),
                                                            actions: <Widget>[
                                                              new FlatButton(
                                                                  child: new Text(
                                                                      'Try Again'),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator
                                                                        .of(context,
                                                                            rootNavigator:
                                                                                true)
                                                                        .pop();
                                                                  })
                                                            ]),
                                                  );
                                                }
                                              });
                                            })
                                      ]),
                            );
                          } else {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) =>
                                  new AlertDialog(
                                      title: new Text("Uninvite"),
                                      content: new Text(
                                          "Are you sure you want to uninvite " +
                                              userInfo.family[index].name +
                                              "?"),
                                      actions: <Widget>[
                                        new FlatButton(
                                            child: new Text('Yes'),
                                            onPressed: () async {
                                              await serverFunctions
                                                  .deleteUser(index)
                                                  .then((value) {
                                                if (value) {
                                                  Navigator
                                                      .of(context,
                                                          rootNavigator: true)
                                                      .pop();
                                                  showDialog(
                                                      context: context,
                                                      barrierDismissible: true,
                                                      builder: (BuildContext
                                                              context) =>
                                                          new AlertDialog(
                                                              title: new Text(
                                                                  "Success"),
                                                              content: new Text(userInfo
                                                                      .family[
                                                                          index]
                                                                      .name +
                                                                  " has been successfully uninvited"),
                                                              actions: <Widget>[
                                                                new FlatButton(
                                                                    child: new Text(
                                                                        "Okay"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator
                                                                          .of(context,
                                                                              rootNavigator: true)
                                                                          .pop();
                                                                    })
                                                              ]));
                                                } else {
                                                  Navigator
                                                      .of(context,
                                                          rootNavigator: true)
                                                      .pop();
                                                  showDialog(
                                                      context: context,
                                                      barrierDismissible: true,
                                                      builder: (BuildContext
                                                              context) =>
                                                          new AlertDialog(
                                                              title: new Text(
                                                                  "Failure"),
                                                              content: new Text(userInfo
                                                                      .family[
                                                                          index]
                                                                      .name +
                                                                  " has not been uninvited"),
                                                              actions: <Widget>[
                                                                new FlatButton(
                                                                    child: new Text(
                                                                        "Okay"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator
                                                                          .of(context,
                                                                              rootNavigator: true)
                                                                          .pop();
                                                                    })
                                                              ]));
                                                }
                                              });
                                            })
                                      ]),
                            );
                          }
                        },
                        child: new Text(
                          userInfo.family[index].invited != "v" &&
                                  userInfo.family[index].invited != "nv"
                              ? "Uninvite"
                              : "Invite",
                          style: myStyle.listButtons(context),
                          textAlign: TextAlign.center,
                        )))
            : new Container()
      ],
    );
  }
}
