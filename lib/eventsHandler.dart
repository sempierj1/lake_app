import 'dart:io';
import 'dart:convert';
import 'dart:async';

class EventsListHandler{

  Future<List> getEvents()async
  {
    var httpClient = new HttpClient();
    var uri = new Uri.https(
        'mediahomecraft.ddns.net', '/lake/getEvents.php');
    var request = await httpClient.getUrl(uri);
    var response = await request.close();
    var responseBody = await response.transform(UTF8.decoder).join();
    List data = JSON.decode(responseBody);
    return data;
  }
}