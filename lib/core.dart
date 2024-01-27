import "package:requests/requests.dart";

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

  static int getStatusCode(Map<String,dynamic> responce){
    int status;
    if(responce.containsKey("error")){
      status = responce["error"][0];
    }else{
      status = 0;
    }
    return status;
  }
}