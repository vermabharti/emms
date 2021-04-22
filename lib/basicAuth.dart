import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';

// Basic Authentication(username/password) of Web service calling

String mobileusername = 'admin';
String mobilepassword = 'adminabc';
String basicAuth =
    'Basic ' + base64Encode(utf8.encode('$mobileusername:$mobilepassword'));
Map<String, String> headers = {
  'content-type': 'text/plain',
  'authorization': basicAuth
};

// SSL Certification (Server Security)

bool trustSelfSigned = true;
HttpClient httpClient = new HttpClient()
  ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => trustSelfSigned);
IOClient ioClient = new IOClient(httpClient);
