import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:io';



List<CameraDescription> cameras;
double heightApp;
double widthApp;
String appDocPath;

class CameraState extends StatefulWidget{
  CameraState({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CameraState createState() => new _CameraState();
}

class _CameraState extends State<CameraState>{
  CameraController controller;

  @override
  void initState() {
    super.initState();
    getPath();

    controller = new CameraController(cameras[1], ResolutionPreset.medium);
    controller.initialize().then((_){
      if(!mounted){
        return;
      }
      setState((){});
    });
  }

  @override
  void dispose(){
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    widthApp = MediaQuery.of(context).size.width;
    heightApp = MediaQuery.of(context).size.height;
    if(!controller.value.initialized){
      return new Container();
    }
        return new Scaffold(
          body: new AspectRatio(aspectRatio:
        controller.value.aspectRatio,
        child: new CameraPreview(controller)),
        floatingActionButton:
          new FloatingActionButton(
            backgroundColor: Colors.red,
            mini: false,
            tooltip: 'Take Picture',
            onPressed: () async{
              await controller.capture(appDocPath + "/profile.jpg");
            },
          ),
          /*new FlatButton(onPressed: (){
            Navigator.pop(context);

            //Navigator.pushNamed(context, '/screen7');
          }, child: new Text("Go Back", style: new TextStyle(fontFamily: 'Roboto', color:Colors.lightBlue, fontSize: 20.0), textAlign: TextAlign.center,))*/



    );

  }
}

Future<Null> getCameras() async {
  cameras = await availableCameras();
}

Future getPath()async{
  Directory appDocDir = await getApplicationDocumentsDirectory();
  appDocPath = appDocDir.path;
}