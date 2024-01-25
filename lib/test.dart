import "package:requests/requests.dart";
void main() async{

  var url_camera = "http://192.168.122.1:8080/sony/camera";
  var url_content = "http://192.168.122.1:8080/sony/avContent";
  var r = await Requests.post(
    url_camera,
    body:{
      "method" : "getAvailableApiList",
      "params" : [
      ],
      "id" : 1,
      "version" : "1.0"
    },
    bodyEncoding: RequestBodyEncoding.JSON
  );

  r.raiseForStatus();
  dynamic json = r.json();
  print(json);


}
