import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var medList;
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  TextEditingController searchController = TextEditingController(text: '');
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pharm-Aware!'),
          centerTitle: true,
          backgroundColor: Colors.blue[100],
        ),
        body: SingleChildScrollView(
          child: Column(
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
                  Container(margin: EdgeInsets.only(left: 10), height: 10, width: 10, child: loading ? CircularProgressIndicator(color: Colors.green) : Container()),
                  IconButton(
                      onPressed: (() async {
                        setState(() {
                          loading = true;
                        });
                        var result = await getMedData(searchController.text);
                        setState(() {
                          medList = result['meds_1mg'];
                          loading = false;
                        });
                      }),
                      icon: const Icon(Icons.medication, color: Colors.red, size: 40))
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: height * 0.76,
                width: width,
                child: medList == null
                    ? Center(child: loading ? CircularProgressIndicator() : Text('Looking for Medicines? search here..'))
                    : ListView.builder(
                        itemCount: medList == null ? 0 : medList.length,
                        itemBuilder: ((context, index) {
                          return Card(
                            borderOnForeground: true,
                            elevation: 20,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            color: Colors.amber.shade50,
                            child: Column(
                              children: [
                                Text("${medList?[index]['title']}", style: TextStyle(fontSize: 20)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [Image.network("${medList?[index]['imageUrl']}"), Text("${medList?[index]['price']}", style: TextStyle(fontSize: 20))],
                                ),
                                Text("${medList?[index]['price']}")
                              ],
                            ),
                          );
                        }),
                      ),
              )
            ],
          ),
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
