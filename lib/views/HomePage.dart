import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmaware/models/medicine.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var medList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pharm-Aware!'),
          centerTitle: true,
          backgroundColor: Colors.blue[100],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 20),
                  height: 50,
                  width: 250,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(border: Border.all(color: Colors.blue.shade100, style: BorderStyle.solid), borderRadius: BorderRadius.circular(25)),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                      hintText: "Search Medicines..",
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                    onPressed: (() async {
                      // (() async {
                      var result = await getMedData(searchController.text);
                      setState(() {
                        medList = result['meds_1mg'];
                      });
                      // })();
                    }),
                    icon: const Icon(Icons.medication, color: Colors.red, size: 40))
              ],
            )
          ],
        ));
  }
}

getMedData(String name) async {
  String url = 'http://10.0.2.2:3000/:${name}';
  final response = await http.get(Uri.parse(url), headers: {"Content-Type": "application/json"});
  final result = json.decode(response.body);
  print(result);
  return result;
}
