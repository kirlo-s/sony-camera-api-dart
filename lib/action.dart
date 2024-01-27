import "core.dart";

class Action{
  String endpoint;
  Action(String this.endpoint);

  Future<List> getAvailableApiList() async{
    String method = "getAvailableApiList";
    dynamic params = [];
    int id = 1;
    String version = "1.0";
    var responce = await Core.call(Core.getCameraUrl(endpoint), method, params, id, version);
    int status = Core.getStatusCode(responce);
    List r = [];
    if(status == 0){
      r = responce["result"][0];
    }
    return r;
  }

  Future<int> startRecMode() async{
    String method = "startRecMode";
    dynamic params = [];
    int id = 1;
    String version = "1.0";
    var responce = await Core.call(Core.getCameraUrl(endpoint), method, params, id, version);
    int status = Core.getStatusCode(responce);
    await _waitUntileModeChange(0);
    return status;
  }

  Future<int> stopRecMode() async{
    String method = "stopRecMode";
    dynamic params = [];
    int id = 1;
    String version = "1.0";
    var responce = await Core.call(Core.getCameraUrl(endpoint), method, params, id, version);
    int status = Core.getStatusCode(responce);
    await _waitUntileModeChange(2);
    return status;
  }

  ///param/mode:
  ///
  ///0:Remote Shooting,1:Contents Transfer,2:Other Funciton 
  Future<int> _waitUntileModeChange(int mode) async{
    int cameraFunction = -1;
    int i = 0;
    while(cameraFunction != mode){
      cameraFunction = await getCameraFunction();
      await Future.delayed(Duration(seconds: 1));
      i++;
    }
    return i;
  }  

  Future<Map<String,dynamic>> getStorageInfo() async{
    String method = "getStorageInformation";
    dynamic params = [];
    int id = 1;
    String version = "1.0";
    var responce = await Core.call(Core.getCameraUrl(endpoint), method, params, id, version);
    int status = Core.getStatusCode(responce);
    var r ={
      "storageDescription":"",
      "numberOfRecordableImages":0,
      "recordTarget" : false,
      "storageID": "No Media",
      "recordableTime": 0,
      "responce" : false
    };
     
    if(status == 0){
      r["storageDescription"]       = responce["result"][0][0]["storageDescription"];
      r["numberOfRecordableImages"] = responce["result"][0][0]["numberOfRecordableImages"];
      r["recordTarget"]             = responce["result"][0][0]["recordTarget"];
      r["storageID"]                = responce["result"][0][0]["storageID"];
      r["recordableTime"]           = responce["result"][0][0]["recordableTime"];
      r["responce"]                 = true;
    }
    return r;
  }  
  
  ///return:  
  ///
  ///0:Remote Shooting,1:Contents Transfer,2:Other Function,-1:Error
  Future<int> getCameraFunction() async{
    int r = 0;
    String method = "getCameraFunction";
    dynamic params = [];
    int id = 1;
    String version = "1.0";
    var responce = await Core.call(Core.getCameraUrl(endpoint), method, params, id, version);  
    int status = Core.getStatusCode(responce);
    if(status == 0){
      String s = responce["result"][0];
      if(s == "Remote Shooting"){
        r = 0;
      }
      if(s == "Contents Transfer"){
        r = 1;
      }
      if(s == "Other Function"){
        r = 2;
      }
    }else{
      r = -1;
    }
    return r;
  }

  ///param:
  ///
  ///0:Remote Shooting,1:Contents Transfer
  Future<int> setCameraFunction(int index) async { 
    final cameraFunction = ["Remote Shooting","Contents Transfer"];
    String method = "setCameraFunction";
    dynamic params = [
      cameraFunction[index]
    ];
    int id = 1;
    String version = "1.0";
    var responce = await Core.call(Core.getCameraUrl(endpoint), method, params, id, version);  
    int status = Core.getStatusCode(responce);
    await _waitUntileModeChange(1);
    return status;
  }

  Future<String> getSource() async{
    String scheme = await _getSchemeList();
    String r = "";
    String method = "getSourceList";
    dynamic params = [
      {
        "scheme" : scheme
      }
    ];
    int id = 1;
    String version = "1.0";
    var responce = await Core.call(Core.getavContentUrl(endpoint), method, params, id, version);
    int status = Core.getStatusCode(responce);
    if(status == 0){
      r = responce["result"][0][0]["source"];
    }else{
      r = status.toString();
    }
    return r;
  }
  
  Future<String> _getSchemeList() async{
    String r = "";
    String method = "getSchemeList";
    dynamic params = [];
    int id = 1;
    String version = "1.0";
    var responce = await Core.call(Core.getavContentUrl(endpoint), method, params, id, version);  
    int status = Core.getStatusCode(responce);
    if(status == 0){
      r = responce["result"][0][0]["scheme"];
    }else{
      r = status.toString();
    }
    return r;
  }

  ///param
  ///
  ///type 0:non-specified,1:still,2:movie_mp4,3:movie_xavcs
  ///
  ///view 0:date,1:flat
  ///
  ///target 0:none,1,all
  ///
  ///return
  ///
  ///positive value:content number,negative value:error code  
  Future<int> getContentCount(String uri,int type,int view,int target) async{
    dynamic t;
    String v;
    int r = 0;
    switch(type){
      case 0:
        t = null;
        break;
      case 1:
        t = "still";
        break;
      case 2:
        t = "movie_mp4";
        break;
      case 3:
        t = "movie_xavcs";
        break;
      default:
        t = null;
        break;
    }
    switch(view){
      case 0:
        v = "date";
        break;
      case 1:
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
        "target": target == 1 ? "all": null,
        "type"  : t,
        "view"  : v
      }
    ];
    int id = 1;
    String version = "1.2"; 
    var responce = await Core.call(Core.getavContentUrl(endpoint), method, params, id, version);  
    int status = Core.getStatusCode(responce);
    if(status == 0){
      r = responce["result"][0]["count"];
    }else{
      r = -status;
    }
    return r;
  }

  Future<List<dynamic>> getContentList(String uri,int stidx,int cnt,int type,int view) async {    
    dynamic t;
    String v;
    List<dynamic> r = [];
    switch(type){
      case 0:
        t = null;
        break;
      case 1:
        t = "still";
        break;
      case 2:
        t = "movie_mp4";
        break;
      case 3:
        t = "movie_xavcs";
        break;
      default:
        t = null;
        break;
    }
    switch(view){
      case 0:
        v = "date";
        break;
      case 1:
        v = "flat";
        break;
      default:
        v = "date";
        break;
    }
    String method = "getContentList";
    dynamic params = [
      {
        "uri"   : uri,
        "stIdx" : stidx,
        "type"  : t,
        "view"  : v,
        "sort"  : "ascending"
      }
    ];
    int id = 1;
    String version = "1.3"; 
    var responce = await Core.call(Core.getavContentUrl(endpoint), method, params, id, version);  
    int status = Core.getStatusCode(responce);
  
    if(status == 0){
      r = responce["result"][0];
    }
    return r;
  }
}