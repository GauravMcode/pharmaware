import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../utils/views_funcs.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var medList = [];
  var descList = [];
  bool loading = false;
  bool fetchError = false;
  IO.Socket? socket;

  @override
  void initState() {
    initSocket();
    super.initState();
  }

  initSocket() {
    socket = IO.io('https://pharmaawarerestapi-production.up.railway.app', <String, dynamic>{
      'autoConnect': false,
      'transports': ['websocket'],
    });
    socket?.connect();
    socket?.onConnect((_) {
      print('Connection established');
      print(socket?.id);
    });
    socket?.onDisconnect((_) => print('Connection Disconnection'));
    socket?.onConnectError((err) => print(err));
    socket?.onError((err) => print(err));
    socket?.on('fetchDescription', (data) {
      setState(() {
        descList.add(data);
      });
    });
    socket?.on('medList', (data) {
      // print(data[0]['title']);
      setState(() {
        medList = data;
      });
    });
  }

  @override
  void dispose() {
    socket?.disconnect();
    socket?.dispose();
    super.dispose();
  }

  TextEditingController searchController = TextEditingController(text: '');
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          leading: medList.isNotEmpty || loading ? Image.asset('assets/default.png', height: 60, width: 60, fit: BoxFit.contain) : Container(),
          elevation: 15,
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
                  Container(margin: const EdgeInsets.only(left: 10), height: 10, width: 10, child: loading ? CircularProgressIndicator(color: Colors.green) : Container()),
                  IconButton(
                      onPressed: (() async {
                        setState(() {
                          if (medList.isNotEmpty && medList.length != descList.length) {
                            socket?.emit('stopEmit', 'stop');
                          }
                          loading = true;
                          descList = [];
                          // medList = [];
                        });
                        var result1 = await getMedData(searchController.text);
                        setState(() {
                          if (result1['statusCode'] != 200) {
                            fetchError = true;
                          } else {
                            fetchError = false;
                            medList = result1['result']['meds_1mg'];
                          }
                          loading = false;
                        });
                      }),
                      icon: const Icon(Icons.medication, color: Colors.red, size: 40))
                ],
              ),
              const SizedBox(height: 20),
              fetchError && !loading
                  ? const Center(child: Text('Some Error occured! Try Again..', style: TextStyle(color: Colors.red)))
                  : Container(
                      height: height * 0.76,
                      width: width,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(40)),
                      child: medList.isEmpty
                          ? Center(
                              child: loading
                                  ? const CircularProgressIndicator()
                                  : Column(children: [
                                      Image.asset('assets/default.png', height: 200, width: 200, fit: BoxFit.contain),
                                      const Text('Looking for Medicines? search here..'),
                                    ]))
                          : ListView.builder(
                              itemCount: medList.length,
                              itemBuilder: ((context, index) {
                                return Card(
                                  borderOnForeground: true,
                                  elevation: 20,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  color: Colors.amber.shade50,
                                  child: Column(
                                    children: [
                                      Text("${medList[index]['title']}", style: const TextStyle(fontSize: 20, color: Colors.blue)),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          medList[index]['imageUrl'] == ""
                                              ? Image.asset('assets/default.png', height: 100, width: 100, fit: BoxFit.contain)
                                              : Image.network("${medList[index]['imageUrl']}"),
                                          Text("${medList[index]['price']}", style: const TextStyle(fontSize: 20, color: Colors.green)),
                                        ],
                                      ),
                                      descList.isNotEmpty && (descList.length >= index + 1)
                                          ? Container(
                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(40)),
                                              child: Text("${descList[index]}"),
                                            )
                                          : loading
                                              ? Container()
                                              : const Text("Loading description..") //descList.length>=index+1?"Loading description..":
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
