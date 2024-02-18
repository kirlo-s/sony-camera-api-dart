import "package:requests/requests.dart";
import "package:sony_camera_api/camera.dart";

import "core.dart";

class Action{
  String endpoint;
  Action(String this.endpoint);

  Future<APIListPayload> getAvailableApiList() async{
    String method = "getAvailableApiList";
    dynamic params = [];
    int id = 1;
    String version = "1.0";
    var responce = await Core.call(Core.getCameraUrl(endpoint), method, params, id, version);
    APIListPayload list = APIListPayload(responce);
    return list;
  }

  Future<CameraStatusPayload> startRecMode() async{
    String method = "startRecMode";
    dynamic params = [];
    int id = 1;
    String version = "1.0";
    var responce = await Core.call(Core.getCameraUrl(endpoint), method, params, id, version);
    CameraStatusPayload payload = CameraStatusPayload(responce);
    await _waitUntileModeChange(CameraFunction.remoteShooting);
    return payload;
  }

  Future<CameraStatusPayload> stopRecMode() async{
    String method = "stopRecMode";
    dynamic params = [];
    int id = 1;
    String version = "1.0";
    var responce = await Core.call(Core.getCameraUrl(endpoint), method, params, id, version);
    CameraStatusPayload payload = CameraStatusPayload(responce);
    await _waitUntileModeChange(CameraFunction.otherFunction);
    return payload;
  }

  ///param/funciton:
  ///
  ///Remote Shooting,Contents Transfer,Other Funciton 
  Future<int> _waitUntileModeChange(CameraFunction function) async{
    CameraFunction cameraFunction = CameraFunction.otherFunction;
    int i = 0;
    while(cameraFunction != function){
      CameraFunctionPayload payload = await getCameraFunction();
      cameraFunction = payload.function;
      await Future.delayed(const Duration(seconds: 1));
      i++;
    }
    return i;
  }  

  Future<StorageInformationPayload> getStorageInfo() async{
    String method = "getStorageInformation";
    dynamic params = [];
    int id = 1;
    String version = "1.0";
    var responce = await Core.call(Core.getCameraUrl(endpoint), method, params, id, version);
    StorageInformationPayload payload = StorageInformationPayload(responce);

    return payload;
  }  
  
  ///return:  
  ///
  ///0:Remote Shooting,1:Contents Transfer,2:Other Function,-1:Error
  Future<CameraFunctionPayload> getCameraFunction() async{
    String method = "getCameraFunction";
    dynamic params = [];
    int id = 1;
    String version = "1.0";
    var responce = await Core.call(Core.getCameraUrl(endpoint), method, params, id, version);  
    CameraFunctionPayload payload = CameraFunctionPayload(responce);
    return payload;
  }
  

  ///param:
  ///
  ///Remote Shooting,Contents Transfer
  Future<CameraStatusPayload> setCameraFunction(CameraFunction function) async { 
    String cameraFunction = "Remote Shooting";

    switch(function){
      case CameraFunction.remoteShooting:
        cameraFunction = "Remote Shooting";
        break;
      case CameraFunction.contentsTransfer:
        cameraFunction = "Contents Transfer";
        break;
      default:
        cameraFunction = "Remote Shooting";
        break;
    }
    String method = "setCameraFunction";
    dynamic params = [
      cameraFunction
    ];
    int id = 1;
    String version = "1.0";
    var responce = await Core.call(Core.getCameraUrl(endpoint), method, params, id, version);  
    CameraStatusPayload payload = CameraStatusPayload(responce);
    await _waitUntileModeChange(function);
    return payload;
  }

  Future<SourcePayload> getSource() async{
    SchemePayload schemePayload = await _getSchemeList();
    String scheme = schemePayload.scheme;
    String method = "getSourceList";
    dynamic params = [
      {
        "scheme" : scheme
      }
    ];
    int id = 1;
    String version = "1.0";
    var responce = await Core.call(Core.getavContentUrl(endpoint), method, params, id, version);
    SourcePayload payload = SourcePayload(responce);
    return payload;
  }
  
  Future<SchemePayload> _getSchemeList() async{
    String method = "getSchemeList";
    dynamic params = [];
    int id = 1;
    String version = "1.0";
    var responce = await Core.call(Core.getavContentUrl(endpoint), method, params, id, version);  
    SchemePayload payload = SchemePayload(responce);
    return payload;
  }

  Future<ContentCountPayload> getContentCount(String uri,ContentType type,ContentView view,bool isTargetAll) async{
    dynamic t;
    String v;
    int r = 0;
    switch(type){
      case ContentType.nonPpecified:
        t = null;
        break;
      case ContentType.still:
        t = "still";
        break;
      case ContentType.mp4:
        t = "movie_mp4";
        break;
      case ContentType.xavcs:
        t = "movie_xavcs";
        break;
      default:
        t = null;
        break;
    }
    switch(view){
      case ContentView.date:
        v = "date";
        break;
      case ContentView.flat:
        v = "flat";
        break;
      default:
        v = "date";
        break;
    }
    String method = "getContentCount";
    dynamic params = [
      {
        "uri"   : uri,
        "target": isTargetAll ? "all": null,
        "type"  : t,
        "view"  : v
      }
    ];
    int id = 1;
    String version = "1.2"; 
    var responce = await Core.call(Core.getavContentUrl(endpoint), method, params, id, version);  
    ContentCountPayload payload = ContentCountPayload(responce);
    return payload;
  }

  Future<ContentListPayload> getContentList(String uri,int startidx,int count,ContentType type,ContentView view,ContentSort sort) async {    
    dynamic t;
    String v;
    String s;
    switch(type){
      case ContentType.nonPpecified:
        t = null;
        break;
      case ContentType.still:
        t = "still";
        break;
      case ContentType.mp4:
        t = "movie_mp4";
        break;
      case ContentType.xavcs:
        t = "movie_xavcs";
        break;
      default:
        t = null;
        break;
    }
    switch(view){
      case ContentView.date:
        v = "date";
        break;
      case ContentView.flat:
        v = "flat";
        break;
      default:
        v = "date";
        break;
    }
    switch(sort){
      case ContentSort.ascending:
        s = "ascending";
        break;
      case ContentSort.descending:
        s = "descending";
        break;
      default:
        s = "ascending";
        break;
    }
    String method = "getContentList";
    dynamic params = [
      {
        "uri"   : uri,
        "stIdx" : startidx,
        "cnt"   : count,
        "type"  : t,
        "view"  : v,
        "sort"  : s
      }
    ];
    int id = 1;
    String version = "1.3"; 
    var responce = await Core.call(Core.getavContentUrl(endpoint), method, params, id, version);  
    ContentListPayload payload = ContentListPayload(responce);
    return payload;
  }

}