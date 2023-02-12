import 'dart:convert';

import 'package:http/http.dart' as http;

getMedData(String name) async {
  String url = 'http://10.0.2.2:3000/${name}';
  final response = await http.get(Uri.parse(url), headers: {"Content-Type": "application/json"});
  final result = json.decode(response.body);
  return result;
}

postDesdata(medList) async {
  var linksList = [];

  medList.forEach((obj) {
    linksList.add(obj['pageUrl']);
  });
  final encoding = Encoding.getByName('utf-8');
  final body = json.encode({"descLinks": linksList});
  String url = 'http://10.0.2.2:3000/description';
  final descResponse = await http.post(Uri.parse(url), encoding: encoding, headers: {"Content-Type": "application/json"}, body: body);
  final result = json.decode(descResponse.body);
  return result;
}
