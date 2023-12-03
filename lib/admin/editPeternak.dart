import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:monitor_broiler/admin/dataPtkPage.dart';
import 'package:http/http.dart' as http;
import 'package:monitor_broiler/admin/monitoringPageAdm.dart';

class UpdatePtk extends StatefulWidget {
  const UpdatePtk({super.key, required this.id});
  final String id;

  @override
  State<UpdatePtk> createState() => _UpdatePtkState();
}

class _UpdatePtkState extends State<UpdatePtk> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController phone_number = TextEditingController();

  Future<void> updateData(String id) async {
    try {
      final response = await http.post(
        Uri.parse("https://apkmonitoring.bantuas.online/editdata.php"),
        body: {
          "id": id,
          "username": username.text,
          "password": password.text,
          "phone_number": phone_number.text,
        },
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData["success"] == "true") {
          print("Data Updated");
        } else {
          print("Error: ${responseData['error']}");
        }
      } else {
        print(
            "Failed to send data to the server. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Ubah Data Peternak"),
        ),
        backgroundColor: Colors.amberAccent[700],
      ),
      drawer: const DrawerContentAdm(),
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    image: DecorationImage(
                      image: AssetImage(
                        "assets/broiler1.png",
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: username,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Username",
                    labelText: "Username",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: password,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Password",
                    labelText: "Password",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: phone_number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Phone Number",
                    labelText: "Phone Number",
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: (() {
                    updateData(widget.id);
                    setState(() {
                      username.text = username.value.text;
                      password.text = password.value.text;
                      phone_number.text = phone_number.value.text;
                      CustomAlert(
                        context,
                        "Data telah di Update",
                      );
                    });
                  }),
                  child: const Text("Selesai")),
            ],
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 250, 250, 250),
    );
  }
}

Future<dynamic> CustomAlert(BuildContext context, String pesan) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.black54,
        title: Text(
          pesan,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        content: Text(
          pesan,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const DataPtkPage()));
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}
