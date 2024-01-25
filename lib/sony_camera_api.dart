library sony_camera_api;


import 'dart:io';
import 'package:udp/udp.dart';
import 'package:xml/xml.dart';
import 'package:requests/requests.dart';

const ADRESS = '239.255.255.250';
const PORT = 1900;
void main(List<String> args) async {
  String xml_url = await discoverer();
  String endpoint = await getEndpoint(xml_url);
}


Future<String> discoverer() async{
  var multicastEndPoint = Endpoint.multicast(InternetAddress(ADRESS),port: Port(PORT));
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
  await for (Datagram? datagram in receiver.asStream()){
    if(datagram != null){
      var str = String.fromCharCodes(datagram.data);
      print("Cont:\n" +str);
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
  return r_spl[8];
}

Future<String> getEndpoint(String xml_url) async {
  String endpoint = "";
  var xmlResponse = await Requests.get(xml_url);
  var xmlData = XmlDocument.parse(xmlResponse.content());
  var url = xmlData.findAllElements('av:X_ScalarWebAPI_ActionList_URL');
  print(url.first);
  print(url.first.innerText);
  return endpoint;
}