import "package:requests/requests.dart";
import "package:sony_camera_api/camera.dart";
import 'core.dart';


/*
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
*/



void main(List<String> args) async {
  Camera camera = Camera();
  //CameraDataPayload f = await camera.searchCamera(60);
  
  camera.initializeDirectly("http://192.168.122.1:8080/sony","","");
  
  CameraStatusPayload s = await camera.action.startRecMode();
  print(s.status);
  CameraFunctionPayload a = await camera.action.getCameraFunction();
  print(a.function);
  print(await camera.action.setCameraFunction(CameraFunction.contentsTransfer));
  var m = await camera.action.getStorageInfo();
  var source = await camera.action.getSource();
  print(source.source);
  var uri = "storage:memoryCard1";
  var uri_folder = "storage:memoryCard1?path=2024-02-24";
  ContentCountPayload payload = await camera.action.getContentCount(uri, ContentType.nonSpecified, ContentView.flat, false);
  print(payload.contentCount);
  ContentListPayload c = await camera.action.getContentList(uri_folder,0,10,ContentType.still,ContentView.date,ContentSort.descending);
  print(c.responce);
  print(c.status);
  print(c.list);
  for(dynamic d in c.list){
    switch(d.type){
      case DataType.still:
        d as StillData;
        print(d.originalUrl);
      case DataType.movie:
        d as MovieData;
        print(d.originalUrl);
      case DataType.directory:
        d as DirectoryData;
        print(d.uri);
    }
  }

  s = await camera.action.setCameraFunction(CameraFunction.remoteShooting);
  s = await camera.action.stopRecMode();
  return;
}
