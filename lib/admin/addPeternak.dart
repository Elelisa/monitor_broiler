import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:monitor_broiler/admin/dataPtkPage.dart';
import 'package:http/http.dart' as http;
import 'package:monitor_broiler/admin/monitoringPageAdm.dart';

class AddPeternak extends StatefulWidget {
  const AddPeternak({super.key});

  @override
  State<AddPeternak> createState() => _AddPeternakState();
}

class _AddPeternakState extends State<AddPeternak> {
  Future<void> insertdata() async {
    if (username.text != "" || password.text != "" || phone_number.text != "") {
      try {
        String uri = "https://apkmonitoring.bantuas.online/insertdata.php";
        var res = await http.post(Uri.parse(uri), body: {
          "username": username.text,
          "password": password.text,
          "phone_number": phone_number.text,
        });
        if (res.statusCode == 200) {
          var response = json.decode(res.body);
          if (response["success"] == "true") {
            print("Data Inserted");
            username.text = "";
            password.text = "";
            phone_number.text = "";
          } else {
            print("Error: ${response['error']}");
          }
        } else {
          print("Failed to send data to server.");
        }
      } catch (e) {
        print(e);
      }
    } else {
      print("Please Fill All Fields");
    }
  }

  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController phone_number = TextEditingController();
  final controllerUsername = TextEditingController();
  final controllerPassword = TextEditingController();
  final controllerPhonenumber = TextEditingController();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Buat Akun Peternak"),
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
                    insertdata();
                    setState(() {
                      username.text = username.value.text;
                      password.text = controllerPassword.value.text;
                      phone_number.text = controllerPhonenumber.value.text;
                      CustomAlert(
                        context,
                        "Selamat datang di Monitoring Bantuas ${username.text}",
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
