import 'package:google_qr/google_qr.dart';
import 'qr.dart';
import 'userinfo.dart';
import 'dart:async';

class QRHandler
{
  EmailHandler email = new EmailHandler();
  QrCode qr = new QrCode(10, 2);
  QRHandler()
  {
  }
  makeQR()async
  {
    await email.setEmail();
    qr.addData(email.getEmail());
    qr.make();
  }
  Future <List<bool>> getQR() async
  {
    await makeQR();
    final List<bool> squares = new List<bool>();
    for(int x = 0; x < qr.moduleCount; x++)
      {
        for(int y = 0; y < qr.moduleCount; y++)
          {
            print (qr.isDark(y, x));
            squares.add(qr.isDark(y,x));
          }
      }
    return squares;
  }
}