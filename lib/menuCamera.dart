import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as IO;
import 'package:image/image.dart' as IMAGE;


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

class _CameraState extends State<CameraState> {
/*  Future<File> _imageFile;

  void _onImageButtonPressed(ImageSource source) {
    setState(() {
      _imageFile = ImagePicker.pickImage(source: source);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Image Picker Example'),
      ),
      body: new Center(
        child: new FutureBuilder<File>(
          future: _imageFile,
          builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.error == null) {
              return new Image.file(snapshot.data);
            } else if (snapshot.error != null) {
              return const Text('error picking image.');
            } else {
              return const Text('You have not yet picked an image.');
            }
          },
        ),
      ),
      floatingActionButton: new Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          new FloatingActionButton(
            heroTag: null,
            onPressed: () => _onImageButtonPressed(ImageSource.gallery),
            tooltip: 'Pick Image from gallery',
            child: new Icon(Icons.photo_library),
          ),
          new Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: new FloatingActionButton(
              heroTag: null,
              onPressed: () => _onImageButtonPressed(ImageSource.camera),
              tooltip: 'Take a Photo',
              child: new Icon(Icons.camera_alt),
            ),
          ),
        ],
      ),
    );
  }
}*/


  CameraController controller;

  @override
  void initState() {
    super.initState();
    getPath();

    controller = new CameraController(cameras[1], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
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
    if (!controller.value.initialized) {
      return new Container();
    }
    return new Scaffold(
      body: new Stack(
      alignment: const Alignment(0.6, 0.6),
      children: <Widget>[
        new AspectRatio(aspectRatio: controller.value.aspectRatio,
            child: new CameraPreview(controller)),
        new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new Opacity(opacity: .9,
                  child: new Container(
                    height: heightApp*(3.5/16),
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
                  height: heightApp*(9/16),
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
                new Opacity(opacity: .9,
                  child: new Container(
                    height: heightApp*(3.5/16),
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
          child: new Container(
          width: widthApp/3,
          height: heightApp*3.5/16,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
              border: new Border.all(width: 2.0, color: const Color(0xFF00E5FF))
          ),
          child: new IconButton(
          onPressed: () async
            {
            await controller.capture(appDocPath + "/profile.png"
            );
            cropImage(context);
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
    );
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

Future getPath()async{
  IO.Directory appDocDir = await getApplicationDocumentsDirectory();
  appDocPath = appDocDir.path;
}
int i = 0;
cropImage(BuildContext context)async
{
  IO.Directory appDocDir = await getApplicationDocumentsDirectory();
  appDocPath = appDocDir.path;
  try {
    IMAGE.Image image = IMAGE.decodeImage(
        new IO.File(appDocPath + "/profile.png").readAsBytesSync());
    //IMAGE.Image imageDest = new IMAGE.Image(widthApp.toInt(), widthApp.toInt());
    //IMAGE.copyInto(imageDest, image);
    //IMAGE.Image rotated = IMAGE.copyRotate(image, -90);

    IMAGE.Image cropped = IMAGE.copyCrop(
        image, (image.width*(3.5/16)).toInt(), 0, image.height, image.height);
    IMAGE.Image rotated = IMAGE.copyRotate(cropped, -90);
    new IO.File(appDocPath + "/profile.png")
      .writeAsBytesSync(IMAGE.encodePng(rotated));
    Navigator.pop(context, true);

  }
  catch(e)
  {
    print(i);
    i++;
    cropImage(context);
  }
}