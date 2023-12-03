import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:monitor_broiler/admin/editPeternak.dart';
import 'package:monitor_broiler/admin/monitoringPageAdm.dart';

class DataPtkPage extends StatefulWidget {
  const DataPtkPage({super.key});

  @override
  State<DataPtkPage> createState() => _DataPtkPageState();
}

class _DataPtkPageState extends State<DataPtkPage> {
  List _listData = [];

  Future _getdata() async {
    try {
      String url = "https://apkmonitoring.bantuas.online/read.php";

      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print("masuk");
        print(response.body);
        final data = jsonDecode(response.body);
        setState(() {
          _listData = data;
        });
      }
    } catch (e) {
      print("gagal");
      print(e);
    }
  }

  Future deleteData(String id) async {
    try {
      final response = await http.post(
          Uri.parse("https://apkmonitoring.bantuas.online/deletedata.php"),
          body: {
            "id": id,
          });

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print("gagal");
      print(e);
    }
  }

  @override
  void initState() {
    _getdata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Data Akun Peternak",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.amberAccent[700],
      ),
      drawer: const DrawerContentAdm(),
      body: ListView.builder(
          itemCount: _listData.length,
          itemBuilder: ((context, index) {
            return Card(
              child: ListTile(
                  title: Text("Username : " +
                      _listData[index]['username'].toString() +
                      "\nTelepon : " +
                      _listData[index]['phone_number'].toString()),
                  subtitle: Text(
                      "Password : " + _listData[index]['password'].toString()),
                  trailing: Container(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: ((context) {
                                  return AlertDialog(
                                    content: const Text(
                                        "Apakah Anda Yakin Ingin Menghapus Akun ini?"),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () {
                                            deleteData(_listData[index]["id"])
                                                .then((value) {
                                              if (value) {
                                                const snackBar = SnackBar(
                                                  content: Text(
                                                      "Data Berhasil Dihapus"),
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                              } else {
                                                const snackBar = SnackBar(
                                                  content: Text(
                                                      "Gagal Menghapus Data"),
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                              }
                                            });
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: ((context) =>
                                                        const DataPtkPage())),
                                                (route) => false);
                                          },
                                          child: const Text("Hapus")),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Batal"),
                                      ),
                                    ],
                                  );
                                }),
                              );
                            },
                            icon: const Icon(Icons.delete)),
                        IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: ((context) {
                                  return AlertDialog(
                                    content: const Text(
                                        "Apakah Anda Yakin Ingin Mengedit Akun ini?"),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      UpdatePtk(
                                                          id: _listData[index]
                                                              ["id"])));
                                        },
                                        child: const Text("Edit"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Batal"),
                                      ),
                                    ],
                                  );
                                }),
                              );
                            },
                            icon: const Icon(Icons.edit)),
                      ],
                    ),
                  )),
            );
          })),
    );
  }
}
