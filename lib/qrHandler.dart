import 'qr.dart';
import 'userinfo.dart';
import 'dart:async';
import 'dart:ui';
import 'dart:math';
import 'dart:typed_data';

class QRHandler
{
  EmailHandler email = new EmailHandler();
  QrCode qr = new QrCode(10, 2);
  QRHandler();

  makeQR()async
  {
    await email.setEmail();
    qr.addData(email.getEmail());
    qr.make();
  }
  Future <Picture> getQR() async
  {

    final PictureRecorder recorder = new PictureRecorder();
    Rect bounds = new Rect.fromLTWH(0.0, 0.0, 57.0, 57.0);
    final Canvas canvas = new Canvas(recorder, bounds);
    final Paint paint = new Paint();
    canvas.drawPaint(new Paint()..color = const Color(0xFFFFFFFF));

    final Size size = bounds.size;
    final double devicePixelRatio = window.devicePixelRatio;
    final Size logicalSize = window.physicalSize / devicePixelRatio;

    canvas.save();
    paint.color = const Color(0xFF000000 );

    await makeQR();

    for(int x = 0; x < qr.moduleCount; x++)
      {
        for(int y = 0; y < qr.moduleCount; y++)
          {
            if(qr.isDark(y, x))
            {
            canvas.drawRect(new Rect.fromLTWH(x*1.0, y*1.0, 1.0, 1.0),paint);
            }
          }
      }
    return recorder.endRecording();
  }

  Future<Scene> composite()async
  {
    final double devicePixelRatio = window.devicePixelRatio;
    final Picture picture = await getQR();
    final Float64List deviceTransform = new Float64List(16)
      ..[0] = devicePixelRatio
      ..[5] = devicePixelRatio
      ..[10] = 1.0
      ..[15] = 1.0;
    final SceneBuilder sceneBuilder = new SceneBuilder()
      ..pushTransform(deviceTransform)
      ..addPicture(Offset.zero, picture)
      ..pop();
    return sceneBuilder.build();
  }
}