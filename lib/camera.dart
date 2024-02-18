library sony_camera_api;

import 'dart:io';
import 'core.dart';
import 'package:udp/udp.dart';
import 'package:xml/xml.dart';
import 'package:requests/requests.dart';
import 'action.dart';

class Camera{
  final SSDP_ADRESS = '239.255.255.250';
  final SSDP_PORT = 1900;
  String endpoint = "";
  late Action action;

  void initializeDirectly(String endpoint){
    this.endpoint = endpoint;
    action = Action(this.endpoint);
    action.setCameraFunction(CameraFunction.remoteShooting);
  }
  
  Future<CameraDataPayload> searchCamera(int timeout) async {
    var xml_url = await _discover(timeout);  
    var ep = await _getEndpointFromXml(xml_url);
    CameraDataPayload data = await _getCameraDataFromXml(xml_url);
    endpoint = ep;
    if(endpoint.isNotEmpty){
      action = Action(endpoint);
    }
    action.setCameraFunction(CameraFunction.remoteShooting);
    return data;
  }

  Future<String> _discover(int timeout) async{
    var multicastEndPoint = Endpoint.multicast(InternetAddress(SSDP_ADRESS),port: Port(SSDP_PORT));
    var receiver = await UDP.bind(multicastEndPoint);
    var sender = await UDP.bind(Endpoint.any());
    List<String> msg = [
      'M-SEARCH * HTTP/1.1\r\n',
      'HOST: %s:%d\r\n',
      'MAN: "ssdp:discover"\r\n',
      'MX: 5\r\n',
      'ST: urn:schemas-sony-com:service:ScalarWebAPI:1\r\n',
      '\r\n'
    ];
    sender.send(msg.join("").codeUnits, multicastEndPoint);
    print("data send");
    String responce = "";
    await for (Datagram? datagram in receiver.asStream(timeout: Duration(seconds: timeout))){
      if(datagram != null){
        var str = String.fromCharCodes(datagram.data);
        if(str.contains('NOTIFY')){
          print("Notify detect");
          responce = str;
          break;
        }
      }else{
        print("data is null");
      }
    }

    sender.close();
    receiver.close();
    List<String> r_spl  = responce.replaceAll("\r\n", " ").split(" ");
    return r_spl.length == 1? "":r_spl[8];
  }

  Future<String> _getEndpointFromXml(String xml_url) async {
    String endpoint = "";
    try{
      var xmlResponse = await Requests.get(xml_url);
      var xmlData = XmlDocument.parse(xmlResponse.content());
      var url = xmlData.findAllElements('av:X_ScalarWebAPI_ActionList_URL');
      endpoint = url.first.innerText;
    }catch(any){
      endpoint = "";
    }
    return endpoint;
  }

  Future<CameraDataPayload> _getCameraDataFromXml(String xml_url) async{
    CameraDataPayload c = CameraDataPayload(get: false, name: "");
    try{
      var xmlResponse = await Requests.get(xml_url);
      var xmlData = XmlDocument.parse(xmlResponse.content());
      var n = xmlData.findAllElements('friendlyName');
      c.name = n.first.innerText;
      c.get = true;
    }catch(any){
      //pass every error
    }
    return c;
  }  
}

class CameraDataPayload{
  bool get;
  String name;
  CameraDataPayload({
    required this.get,
    required this.name,
  });
}



/*
void main(List<String> args) async {
  Camera camera = Camera();
  bool f = await camera.searchCamera(60);
  
  //camera.initializeDirectly("http://192.168.122.1:8080/sony");
  
  int s = await camera.action.startRecMode();
  print(s);
  int a = await camera.action.getCameraFunction();
  print(a);
  print(await camera.action.setCameraFunction(1));
  var m = await camera.action.getStorageInfo();
  var source = await camera.action.getSource();
  print(source);
  var uri = "storage:memoryCard1?path=2024-01-23";
  dynamic c = await camera.action.getContentList(uri,0,100,0,0,0);
  for(Map<String,dynamic> p in c){
    print(p);
  }

  var p = await Requests.get("http://192.168.122.1:8080/contentstransfer/thumb/index%3A%2F%2F1000%2F00000001-default%2F0000001B-00000943_27_1_1000");
  
  print(p.body.runtimeType);
  print(m);
  s = await camera.action.stopRecMode();
  return;
}
*/