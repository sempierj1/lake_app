import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as IO;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'qrScan.dart';

List<CameraDescription> cameras;
double heightApp;
double widthApp;
String appDocPath;
int i = 0;
String test = "";

class CameraState extends StatefulWidget {
  CameraState({Key key, this.title, this.list}) : super(key: key);

  final String title;
  final List list;

  @override
  _CameraState createState() => new _CameraState(list);
}

class _CameraState extends State<CameraState> {
  CameraController controller;

  final List list;

  _CameraState(this.list);

  @override
  void initState() {
    super.initState();
    getPath();
    getCameras();

    _finishInit() {
      for (int i = 0; i < cameras.length; i++) {
        if (cameras[i].lensDirection == CameraLensDirection.back) {
          controller =
              new CameraController(cameras[i], ResolutionPreset.medium);
        }
      }
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    }

    Future _cameraCheck() async {
      if (cameras != null) {
        _finishInit();
      } else
        new Future.delayed(new Duration(seconds: 1), _cameraCheck);
    }

    new Future.delayed(new Duration(milliseconds: 500), _cameraCheck);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widthApp = MediaQuery.of(context).size.width;
    heightApp = MediaQuery.of(context).size.height;
    if (controller == null) {
      return new Container();
    } else if (!controller.value.isInitialized) {
      return new Container();
    }
    return new Scaffold(
      body: new ListView(children: <Widget>[
        new Column(children: <Widget>[
          new AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: new CameraPreview(controller)),
        ])
      ]),
      floatingActionButton: new IconButton(
        onPressed: () async {
          test = "";
          test += DateTime.now().toString() + "\n";
          await controller
              .takePicture(appDocPath + "/profile" + i.toString() + ".png")
              .then((String value) {
            test += DateTime.now().toString() + "\n";
            cropImage(context, list[0], list[1]);
          });
        },
        icon: new Icon(Icons.camera_alt),
        iconSize: widthApp / 6,
        splashColor: Colors.red,
        color: Colors.lightBlue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

Future<Null> getCameras() async {
  cameras = await availableCameras();
  print(cameras);
  print(cameras[0].lensDirection);
}

Future getPath() async {
  IO.Directory appDocDir = await getApplicationDocumentsDirectory();
  appDocPath = appDocDir.path;
}

cropImage(BuildContext context, String n, String uid) async {
  //const platform = const MethodChannel('com.yourcompany.flutter/readWrite');
  //final List<int> result = await platform.invokeMethod('getFile');
  final String name = n;

  IO.Directory appDocDir = await getApplicationDocumentsDirectory();
  appDocPath = appDocDir.path;
  IO.File image = new IO.File(appDocPath + "/profile" + i.toString() + ".png");
  try {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) => new AlertDialog(
            title: new Text("Upload?"),
            content: new Container(
                height: 200.0,
                child: new Column(
                  children: <Widget>[
                    new Center(
                      child: new CircleAvatar(
                        backgroundImage: FileImage(image),
                        radius: widthApp / 8,
                      ),
                      //child: new Image(image: new FileImage(new File(appDocPath))),
                    ),
                    new Container(height: 35.0),
                    new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new FlatButton(
                            onPressed: () async {
                              i++;
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) =>
                                      new AlertDialog(
                                        title: new Text("Uploading Picture"),
                                        content: new Container(
                                          height: 200.0,
                                          child: new Center(
                                            child: new SizedBox(
                                              height: 50.0,
                                              width: 50.0,
                                              child:
                                                  new CircularProgressIndicator(
                                                value: null,
                                                strokeWidth: 7.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ));
                              //IMAGE.Image cropped = IMAGE.copyCrop(
                              //    image, 0, 0, image.height,
                              //    image.height);
                              //List<String> nameSplit = _controller.text.split(" ");
                              //String name = nameSplit[0] + "_" + nameSplit[1];
                              final StorageReference ref = FirebaseStorage
                                  .instance
                                  .ref()
                                  .child(name + ".png");
                              final StorageUploadTask uploadTask = ref.putFile(
                                  image,
                                  StorageMetadata(contentLanguage: "en"));
                              final Uri downloadUrl =
                                  (await uploadTask.future).downloadUrl;
                              var url =
                                  'https://membershipme.ddns.net/node/addPic';
                              await http
                                  .post(url,
                                      body: {
                                        "picURL": downloadUrl.toString(),
                                        "name": name
                                      },
                                      encoding: Encoding.getByName("utf-8"))
                                  .then((response) {
                                if (response.body.toString() == "Success") {}
                              });
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) =>
                                          new QrScanner(uid: uid)),
                                  ModalRoute.withName('/screen8'));
                            },
                            child: new Text(
                              "Yes",
                              style: new TextStyle(
                                  fontFamily: 'Roboto',
                                  color: Colors.lightBlue,
                                  fontSize: 20.0),
                            ),
                          ),
                        ),
                        new Expanded(
                          child: new FlatButton(
                            onPressed: () {
                              i++;
                              Navigator.pop(context);
                            },
                            child: new Text(
                              "No",
                              style: new TextStyle(
                                  fontFamily: 'Roboto',
                                  color: Colors.lightBlue,
                                  fontSize: 20.0),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ))));
  } catch (e) {}
}
