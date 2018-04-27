import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as IO;
import 'package:image/image.dart' as IMAGE;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


List<CameraDescription> cameras;
double heightApp;
double widthApp;
String appDocPath;
int i = 0;
TextEditingController _controller = new TextEditingController();
String test = "";


class CameraState extends StatefulWidget {
  CameraState({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CameraState createState() => new _CameraState();
}

class _CameraState extends State<CameraState> {
  CameraController controller;

  @override
  void initState() {
    super.initState();
    getPath();
    getCameras();

    _finishInit() {
      controller = new CameraController(cameras[0], ResolutionPreset.medium);
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
    widthApp = MediaQuery
        .of(context)
        .size
        .width;
    heightApp = MediaQuery
        .of(context)
        .size
        .height;
    if (controller == null) {
      return new Container();
    }
    else if (!controller.value.initialized) {
      return new Container();
    }
    return new Scaffold(
      body: new ListView(
        children: <Widget>[
          new Column(
          children: <Widget>[
        new Stack(
        //alignment: const Alignment(0.6, 0.6),
        children: <Widget>[
          new AspectRatio(aspectRatio: controller.value.aspectRatio,
              child: new CameraPreview(controller)),
          new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new Opacity(opacity: 1.0,
                    child: new Container(
                      height: heightApp * (2 / 16),
                      width: widthApp,
                      decoration: new BoxDecoration(
                          color: Colors.white
                      ),
                    ),
                  )
                ],
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new Container(
                    height: heightApp * (9 / 16),
                    width: widthApp,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent
                    ),
                  ),

                ],
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new Opacity(opacity: 1.0,
                    child: new Container(
                      height: heightApp * (4.0 / 16),
                      width: widthApp,
                      decoration: new BoxDecoration(
                          color: Colors.white

                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
          new Align(
            alignment: Alignment.bottomCenter,
            heightFactor: 3.7,
            child: new Container(
              width: widthApp / 3,
              height: heightApp * 4.0 / 16,
              decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  border: new Border.all(
                      width: 2.0, color: const Color(0xFF00E5FF))
              ),
              child: new IconButton(
                onPressed: () async
                {
                  test ="";
                  test += DateTime.now().toString() + "\n";
                  await controller.capture(appDocPath + "/profile" + i.toString() + ".png"
                  ).then((String value){
                    test += DateTime.now().toString() + "\n";
                    cropImage(context);
                  });
                  },
                icon: new Icon(Icons.camera_alt),
                iconSize: widthApp / 6,
                splashColor: Colors.red,
              ),
            ),
          ),
          /*new Container(
          decoration: new BoxDecoration(
            //shape: BoxShape.circle,
            color: Colors.grey,
            /*border: const Border(
            top: const BorderSide(width: 2.0, color: const Color(0xFFFFFFFFFF)),
            left: const BorderSide(width: 2.0, color: const Color(0xFFFFFFFFFF)),
            right: const BorderSide(width: 2.0, color: const Color(0xFFFFFFFFFF)),
            bottom: const BorderSide(width: 2.0, color: const Color(0xFFFFFFFFFF))),*/

          ),
          child: new Container(
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              border: const Border(
                  top: const BorderSide(width: 2.0, color: const Color(0xFFFFFFFFFF)),
                  left: const BorderSide(width: 2.0, color: const Color(0xFFFFFFFFFF)),
                  right: const BorderSide(width: 2.0, color: const Color(0xFFFFFFFFFF)),
                  bottom: const BorderSide(width: 2.0, color: const Color(0xFFFFFFFFFF))),
            ),
          ),


        ),*/
        ],
      ),
    ])],
      ));
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Take a Profile Picture'),
      ),
      body: new AspectRatio(aspectRatio: controller.value.aspectRatio,
          child: new CameraPreview(controller)),


    );

    /*backgroundColor: Colors.red,
            mini: false,
            tooltip: 'Take Picture',
            onPressed: () async {
              await controller.capture(appDocPath + "/profile.jpg");*/
    /*new FlatButton(onPressed: (){
            Navigator.pop(context);

            //Navigator.pushNamed(context, '/screen7');
          }, child: new Text("Go Back", style: new TextStyle(fontFamily: 'Roboto', color:Colors.lightBlue, fontSize: 20.0), textAlign: TextAlign.center,))*/


  }
}


Future<Null> getCameras() async {
  cameras = await availableCameras();
}

Future getPath() async {
  IO.Directory appDocDir = await getApplicationDocumentsDirectory();
  appDocPath = appDocDir.path;
}


cropImage(BuildContext context) async
{
  IO.Directory appDocDir = await getApplicationDocumentsDirectory();
  appDocPath = appDocDir.path;
  try {

    test += "Start f" + DateTime.now().toString() + "\n";
    print(DateTime.now());
    IMAGE.Image image = IMAGE.decodeImage(
        new IO.File(appDocPath + "/profile" + i.toString() + ".png").readAsBytesSync());
    test += "File read " + DateTime.now().toString() + "\n";
    print("File read");
    print(DateTime.now());
    //IMAGE.Image imageDest = new IMAGE.Image(widthApp.toInt(), widthApp.toInt());
    //IMAGE.copyInto(imageDest, image);
    //IMAGE.Image rotated = IMAGE.copyRotate(image, -90);
    IMAGE.Image cropped = IMAGE.copyCrop(
        image, (image.width * (5.0/ 16)).toInt(), (image.height * (2 / 9)).toInt(), (image.height * (5 / 9)).toInt(),
        (image.height * (5 / 9)).toInt());
    test += "File cropped " + DateTime.now().toString() + "\n";
    print("File cropped");
    print(DateTime.now());
    IMAGE.Image rotated = IMAGE.copyRotate(cropped, 90);
    test += "File rotated" + DateTime.now().toString() + "\n";
    print("File rotated");
    print(DateTime.now());
    new IO.File(appDocPath + "/profile" + i.toString() + ".png")
        .writeAsBytesSync(IMAGE.encodePng(rotated));
    test += "File written " + DateTime.now().toString() + "\n";
    print("File written");
    print(DateTime.now());
    IO.File upload = new IO.File(appDocPath + "/profile" + i.toString() + ".png");
    test += "File set for upload " + DateTime.now().toString() + "\n";
    print("File set for upload");
    print(DateTime.now());
    showDialog(context: context,
    barrierDismissible: true,
    builder: (BuildContext context) =>
    new AlertDialog(
        title: new Text("Upload?"),
        content: new Text(test)));
    /*showDialog(context: context,
    barrierDismissible: true,
    builder: (BuildContext context) =>
    new AlertDialog(
      title: new Text("Upload?"),
      content:
      new Container(
        height: 200.0,
         child: new Column(
        children: <Widget>[
        new Center(
          child: new CircleAvatar(
            backgroundImage: FileImage(upload),
            radius: widthApp / 7,
          ),
          //child: new Image(image: new FileImage(new File(appDocPath))),
        ),
        new Container(height: 35.0),
        new Row(
          children: <Widget>[
            new Expanded(child:
            new FlatButton(onPressed: (){
              i++;
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) =>
                new AlertDialog(
                    title: new Text("Name"),
                    content: new TextField(
                      controller: _controller,
                      decoration: new InputDecoration(
                        hintText: 'John Smith',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    actions: <Widget>[
                      new FlatButton(
                          child: new Text('Add Picture'), onPressed: () async {
                        showDialog(context: context,
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
                                    child: new CircularProgressIndicator(
                                      value: null,
                                      strokeWidth: 7.0,
                                    ),
                                  ),
                                ),),)
                        );
                        //IMAGE.Image cropped = IMAGE.copyCrop(
                        //    image, 0, 0, image.height,
                        //    image.height);
                        List<String> nameSplit = _controller.text.split(" ");
                        String name = nameSplit[0] + "_" + nameSplit[1];
                        final StorageReference ref = FirebaseStorage.instance.ref().child(
                            name + ".png");
                        final StorageUploadTask uploadTask = ref.putFile(
                            upload, const StorageMetadata(contentLanguage: "en"));
                        final Uri downloadUrl = (await uploadTask.future).downloadUrl;

                        var url = 'https://mediahomecraft.ddns.net/node/addPic';
                        await http
                            .post(url,
                            body: {
                              "picURL": downloadUrl.toString(),
                              "name": _controller.text
                            },
                            encoding: Encoding.getByName("utf-8"))
                            .then((response) {
                          if (response.body.toString() == "Success") {}
                        });
                        Navigator.popAndPushNamed(context, "/screen6");
                      }

                      )
                    ]),
              );
            }, child: new Text("Yes", style: new TextStyle(fontFamily: 'Roboto',
                color: Colors.lightBlue,
                fontSize: 20.0),),),),
            new Expanded(child:
            new FlatButton(onPressed: (){
              i++;
              Navigator.pop(context);
              }, child: new Text("No", style: new TextStyle(fontFamily: 'Roboto',
                color: Colors.lightBlue,
                fontSize: 20.0),),),)
          ],
          )
      ],
    )

    )));*/

  }
  catch (e) {
  }
}
