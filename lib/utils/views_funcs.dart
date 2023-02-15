import 'dart:convert';

import 'package:http/http.dart' as http;

getMedData(String name) async {
  String url = 'https://pharmaawarerestapi-production.up.railway.app/${name}';
  final response = await http.get(Uri.parse(url), headers: {"Content-Type": "application/json"});
  final result = json.decode(response.body);
  return {"result": result, "statusCode": response.statusCode};
}
