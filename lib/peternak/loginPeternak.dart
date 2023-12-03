import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:monitor_broiler/peternak/monitoringPagePtk.dart';

class LoginPagePeternak extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Login Peternak"),
        ),
        backgroundColor: Colors.amberAccent[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: LoginFormPeternak(),
    );
  }
}

class LoginFormPeternak extends StatefulWidget {
  @override
  _LoginFormPeternakState createState() => _LoginFormPeternakState();
}

class _LoginFormPeternakState extends State<LoginFormPeternak> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  Future _login() async {
    final response = await http
        .post(Uri.parse('https://apkmonitoring.bantuas.online/login.php'),
            //Uri.parse('http://192.168.75.99/monitoring_api/login.php'),
            body: {
          "username": _username.text,
          "password": _password.text,
        });

    var datauser = json.decode(response.body);

    if (datauser.length == 0) {
      setState(() {
        const AlertDialog(
          title: Text("Akun belum terdaftar"),
        );
      });
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => MonitoringPagePtk()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                image: const DecorationImage(
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
              controller: _username,
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
              controller: _password,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Password",
                labelText: "Password",
              ),
              obscureText: true,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          TextButton(
            onPressed: _login,
            child: Text('Login'),
          ),
        ],
      ),
    ]);
  }
}
