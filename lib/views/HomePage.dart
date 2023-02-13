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
  IO.Socket? socket;

  @override
  void initState() {
    initSocket();
    super.initState();
  }

  initSocket() {
    socket = IO.io('http://10.0.2.2:3000', <String, dynamic>{
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
                          medList = result1['meds_1mg'];
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
                child: medList.isEmpty
                    ? Center(child: loading ? const CircularProgressIndicator() : const Text('Looking for Medicines? search here..'))
                    : ListView.builder(
                        // children: [
                        //   List.generate(length, (index) => null)
                        // ],
                        itemCount: medList.length,
                        itemBuilder: ((context, index) {
                          return Card(
                            borderOnForeground: true,
                            elevation: 20,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            color: Colors.amber.shade50,
                            child: Column(
                              children: [
                                Text("${medList[index]['title']}", style: const TextStyle(fontSize: 20)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    medList[index]['imageUrl'] == "" ? Image.asset('assets/default.png', height: 100, width: 100, fit: BoxFit.contain) : Image.network("${medList[index]['imageUrl']}"),
                                    Text("${medList[index]['price']}", style: const TextStyle(fontSize: 20)),
                                  ],
                                ),
                                descList.isNotEmpty && (descList.length >= index + 1)
                                    ? Text("${descList[index]}")
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
