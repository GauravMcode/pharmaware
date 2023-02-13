import 'dart:convert';

import 'package:http/http.dart' as http;

getMedData(String name) async {
  String url = 'http://10.0.2.2:3000/${name}';
  final response = await http.get(Uri.parse(url), headers: {"Content-Type": "application/json"});
  final result = json.decode(response.body);
  return result;
}
