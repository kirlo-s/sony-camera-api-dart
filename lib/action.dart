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
    return status;
  }

  Future<int> stopRecMode() async{
    String method = "stopRecMode";
    dynamic params = [];
    int id = 1;
    String version = "1.0";
    var responce = await Core.call(Core.getCameraUrl(endpoint), method, params, id, version);
    int status = Core.getStatusCode(responce);
    return status;
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
    return status;
  } 
}