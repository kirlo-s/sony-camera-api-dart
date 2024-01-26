library sony_camera_api;


import 'dart:io';
import 'package:udp/udp.dart';
import 'package:xml/xml.dart';
import 'package:requests/requests.dart';
import 'action.dart';

class Camera{
  final SSDP_ADRESS = '239.255.255.250';
  final SSDP_PORT = 1900;
  String endpoint = "";
  late Action action;

  void initializeAction(){
    action = Action(this.endpoint);
  }
  
  Future<bool> setEndpoint(int timeout) async {
    var xml_url = await _discover(timeout);  
    var ep = await _getEndpointFromXml(xml_url);
    this.endpoint = ep;
    if(endpoint.isNotEmpty){
      action = Action(this.endpoint);
    }
    return endpoint.isNotEmpty ? true : false;
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


}
void main(List<String> args) async {
  Camera camera = Camera();
  //bool f = await camera.setEndpoint(60);
  
  /*
    Delete Later
  */
  camera.endpoint = "http://192.168.122.1:8080/sony";
  camera.initializeAction();
  
  int a = await camera.action.getCameraFunction();
  print(a);
  int s = await camera.action.startRecMode();
  print(s);
  await Future.delayed(Duration(seconds: 10));
  a = await camera.action.getCameraFunction();
  print(a);
  print(await camera.action.setCameraFunction(1));
  var m = await camera.action.getStorageInfo();
  print(m);
  await Future.delayed(Duration(seconds: 10));
  s = await camera.action.stopRecMode();
  return;
}
