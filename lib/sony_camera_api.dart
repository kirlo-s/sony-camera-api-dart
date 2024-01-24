library sony_camera_api;

import 'dart:io';
import 'package:udp/udp.dart';

const ADRESS = '239.255.255.250';
const PORT = 1900;
void main(List<String> args) async {
  String str = await getData();
  print(str);
}


Future<String> getData() async{
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
  var received;
    await for (Datagram? datagram in receiver.asStream()){
    if(datagram != null){
      var str = String.fromCharCodes(datagram.data);
      print("Cont:" +str);
      if(str.contains('NOTIFY')){
        print("Notify detect");
        received = str;
        break;
      }
    }else{
      print("data is null");
    }
  }
  sender.close();
  receiver.close();
  return received;
}