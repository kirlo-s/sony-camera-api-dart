import "package:requests/requests.dart";

enum ResponceStatus {success,illegalArgument,illegalRequest,noSuchMethod_,otherErrors}
enum CameraFunction {remoteShooting,contentsTransfer,otherFunction}
enum ContentType {nonSpecified,still,mp4,xavcs}
enum ContentView {date,flat}
enum ContentSort {ascending,descending}
enum DataType {still,movie,directory}

class Core{
  static String getavContentUrl(String url) {
    String avContentUrl = "$url/avContent";
    return avContentUrl;
  }

  static String getCameraUrl(String url){
    String cameraUrl = "$url/camera";
    return cameraUrl;
  }

  static String getSystemUrl(String url){
    String systemUrl = "$url/system";
    return systemUrl;
  }

  static Future<Map<String,dynamic>> call(String url,String method,dynamic params,int id,String version) async {
    Map<String,dynamic> body = createJsonBody(method, params, id, version);
    dynamic responce;
    try{
      var r = await Requests.post(url,body: body,bodyEncoding: RequestBodyEncoding.JSON); 
      r.raiseForStatus();
      responce = r.json();
    } on Exception{
      responce = {"error" : [1601,"Timeout"]};
    }
    return responce;
  }

  static Map<String,dynamic> createJsonBody(String method,dynamic params,int id,String version){
    var body = {
      "method" : method,
      "params" : params,
      "id"     : id,
      "version": version 
    };

    return body;
  }

}

class CameraStatusPayload{
  late ResponceStatus status;

  CameraStatusPayload(Map<String,dynamic> responce){
    status = getStatus(responce);
  }

  ResponceStatus getStatus(Map<String,dynamic> responce){
    int s;
    if(responce.containsKey("error")){
      s = responce["error"][0];
    }else{
      s = 0;
    }
    switch(s){
      case 0:
        return ResponceStatus.success;
      case 3:
        return ResponceStatus.illegalArgument;
      case 5:
        return ResponceStatus.illegalRequest;
      case 12:
        return ResponceStatus.noSuchMethod_;
      default:
        return ResponceStatus.otherErrors;
    }
  }
}

class APIListPayload extends CameraStatusPayload{
  late List<dynamic> apiList;
  APIListPayload(Map<String,dynamic> responce): super(responce){
    _setList(responce);
  }
  void _setList(Map<String,dynamic> responce){
    if(status == ResponceStatus.success){
      apiList = responce["result"][0];
    }else{
      apiList = [];
    }
  }
}

class StorageInformationPayload extends CameraStatusPayload{
  String storageDescription = "";
  int numberOfRecordableImages = 0;
  bool recordTarget = false;
  String storageID = "No Media";
  int recordableTime = 0;
  
  StorageInformationPayload(Map<String,dynamic> responce): super(responce){
    _setInfo(responce);
  }

  void _setInfo(Map<String,dynamic> responce){
    if(status == ResponceStatus.success){
      storageDescription        = responce["result"][0][0]["storageDescription"];
      numberOfRecordableImages  = responce["result"][0][0]["numberOfRecordableImages"];
      recordTarget              = responce["result"][0][0]["recordTarget"];
      storageID                 = responce["result"][0][0]["storageID"];
      recordableTime            = responce["result"][0][0]["recordableTime"];      
    }
  }
}

class CameraFunctionPayload extends CameraStatusPayload{
  CameraFunction function = CameraFunction.otherFunction;
  CameraFunctionPayload(Map<String,dynamic> responce): super(responce){
    _setFunction(responce);
  }

  void _setFunction(Map<String,dynamic> responce){
    if(status == ResponceStatus.success){
      var s = responce["result"][0];
      if(s == "Remote Shooting"){
        function = CameraFunction.remoteShooting;
      }
      if(s == "Contents Transfer"){
        function = CameraFunction.contentsTransfer;
      }
      if(s == "Other Funciton"){
        function = CameraFunction.otherFunction;
      }
    }
  }
}

class SourcePayload extends CameraStatusPayload{
  String source = "";
  SourcePayload(Map<String,dynamic> responce): super(responce){
    _setData(responce);
  }
  void _setData(Map<String,dynamic> responce){
    if(status == ResponceStatus.success){
      source = responce["result"][0][0]["source"];
    }
  }
}

class SchemePayload extends CameraStatusPayload{
  String scheme = "";
  SchemePayload(Map<String,dynamic> responce): super(responce){
    _setData(responce);
  }

  void _setData(Map<String,dynamic> responce){
    if(status == ResponceStatus.success){
      scheme = responce["result"][0][0]["scheme"];
    }
  }
}

class ContentCountPayload extends CameraStatusPayload{
  int contentCount = -1;
  ContentCountPayload(Map<String,dynamic> responce):super(responce){
    _setData(responce);
  }
  void _setData(Map<String,dynamic> responce){
    if(status == ResponceStatus.success){
      contentCount = responce["result"][0]["count"];
    }
  }
}

class StillData {
  DataType type = DataType.still;
  late String uri;
  late String fileName;
  late String originalUrl;
  late String smallUrl;
  late String largeUrl;
  late String thumbnailUrl;
  late DateTime createdTime;

  StillData(Map<String,dynamic> imageData){
    _parseFromResult(imageData);
  }

  void _parseFromResult(Map<String,dynamic> data){
    uri = data["uri"];
    fileName = data["content"]["original"][0]["fileName"];
    originalUrl = data["content"]["original"][0]["url"];
    smallUrl = data["content"]["smallUrl"];
    largeUrl = data["content"]["largeUrl"];
    thumbnailUrl = data["content"]["thumbnailUrl"];
    createdTime = DateTime.parse(data["createdTime"]);
  }
}

class MovieData {
  DataType type = DataType.movie;
  late String uri;
  late String fileName;
  late String originalUrl;
  late String thumbnailUrl;
  late DateTime createdTime;

  MovieData(Map<String,dynamic> imageData){
    _parseFromResult(imageData);
  }

  void _parseFromResult(Map<String,dynamic> data){
    uri = data["uri"];
    fileName = data["content"]["original"][0]["fileName"];

    originalUrl = data["content"]["original"][0]["url"];
    thumbnailUrl = data["content"]["thumbnailUrl"];
    createdTime = DateTime.parse(data["createdTime"]);
  }
}

class DirectoryData {
  DataType type = DataType.directory;
  late String uri;
  late String directoryName;

  DirectoryData(Map<String,dynamic> imageData){
    _parseFromResult(imageData);
  }

  void _parseFromResult(Map<String,dynamic> data){
    uri = data["uri"];
    directoryName = data["title"];
  }
}

class ContentListPayload extends CameraStatusPayload{
  List<dynamic> list = [];
  late Map<String,dynamic> responce;
  ContentListPayload(this.responce):super(responce){
    _setList(responce);
  }
  void _setList(Map<String,dynamic>responce){
    if(status == ResponceStatus.success){
      List<dynamic> responcel = responce["result"][0];
      dynamic data;
      for(dynamic item in responcel){
        String contentKind = item["contentKind"];
        switch(contentKind){
          case "still":
            data = StillData(item);
            break;
          case "movie_mp4" || "movie_xavcs":
            data = MovieData(item);
            break;
          case "directory":
            data = DirectoryData(item);
            break;
          default:
            data = StillData(item);
            break;
        }
        list.add(data);
      }
    }
  }
}
