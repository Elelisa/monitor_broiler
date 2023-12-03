import 'dart:convert';
import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:monitor_broiler/admin/monitoringPageAdm.dart';

class FuzzyMamdaniPage extends StatefulWidget {
  @override
  _FuzzyMamdaniPageState createState() => _FuzzyMamdaniPageState();
}

class _FuzzyMamdaniPageState extends State<FuzzyMamdaniPage> {
  double zblower = 0.0;
  double zheater = 0.0;
  double zcoolPad = 0.0;
  double suhu = 0.0;
  double kelembaban = 0.0;
  double ammonia = 0.0;
  List<Map<String, String>> hasilAksiList = [];
  List<Map<String, dynamic>> _listData = [];

  Future _getdata() async {
    try {
      String url = "http://192.168.75.99/monitoring_api/getriwayat_data.php";
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print("masuk");
        print(response.body);
        final data = jsonDecode(response.body);
        final List<Map<String, dynamic>> dataList =
            List<Map<String, dynamic>>.from(data);
        setState(() {
          _listData = dataList;
        });
        hitungAksi();
      }
    } catch (e) {
      print("gagal");
      print(e);
    }
  }

  Future<void> hitungAksi() async {
    for (var datalist in _listData) {
      // Extract values for temp, hum, and amm from each item in the list
      var hasilAksi = '';
      var temp = datalist["suhu"];
      var hum = datalist["kelembaban"];
      var amm = datalist["ammonia"];
      //Check if temp, hum, and amm are not empty before parsing to double
      if (temp != null && temp.isNotEmpty) {
        suhu = double.parse(temp);
      } else {
        // Handle the case where temp is empty or null
        suhu = 0.0;
      }

      if (hum != null && hum.isNotEmpty) {
        kelembaban = double.parse(hum);
      } else {
        // Handle the case where hum is empty or null
        kelembaban = 0.0;
      }

      if (amm != null && amm.isNotEmpty) {
        ammonia = double.parse(amm);
      } else {
        // Handle the case where amm is empty or null
        ammonia = 0.0;
      }

      //Tahap Fuzzifikasi
      //Menentukan derajat keanggotaan pada setiap himpunan
      //derajat keanggotaan suhu
      double suhuDingin = (suhu > 29 && suhu < 35)
          ? (35 - suhu) / (35 - 29)
          : (suhu < 29)
              ? 1.0
              : 0.0;
      double suhuPanas = (suhu > 29 && suhu < 35)
          ? (suhu - 29) / (35 - 29)
          : (suhu < 29)
              ? 0.0
              : 1.0;
      double suhuNormal = (suhu > 29 && suhu < 32)
          ? (suhu - 29) / (32 - 29)
          : (suhu > 32 && suhu < 35)
              ? (35 - suhu) / (35 - 32)
              : (suhu <= 29 || suhu >= 35)
                  ? 0.0
                  : 1.0;

      //derajat keanggotaan kelembaban
      double kelembabanTinggi = (kelembaban > 60 && kelembaban < 70)
          ? (kelembaban - 60) / (70 - 60)
          : (kelembaban < 60)
              ? 0.0
              : 1.0;
      double kelembabanRendah = (kelembaban > 60 && kelembaban < 70)
          ? (70 - kelembaban) / (70 - 60)
          : (kelembaban < 60)
              ? 1.0
              : 0.0;
      double kelembabanNormal = (kelembaban > 60 && kelembaban < 65)
          ? (kelembaban - 60) / (65 - 60)
          : (kelembaban > 65 && kelembaban < 70)
              ? (70 - kelembaban) / (70 - 65)
              : (kelembaban <= 60 || kelembaban >= 70)
                  ? 0.0
                  : 1.0;

      //derajat keanggotaan amonia
      double amoniaCukup = (ammonia >= 15 && ammonia <= 25)
          ? (25 - ammonia) / (25 - 15)
          : (ammonia < 15)
              ? 1.0
              : 0.0;
      double amoniaBerlebih = (ammonia > 5 && ammonia < 25)
          ? (ammonia - 5) / (25 - 5)
          : (ammonia < 5)
              ? 0.0
              : 1.0;

      // Inferensi (gunakan aturan fuzzy)
      //terdapat 18 aturan:
      double r1 = min(min(suhuDingin, kelembabanTinggi), amoniaCukup);
      double r2 = min(min(suhuDingin, kelembabanTinggi), amoniaBerlebih);
      double r3 = min(min(suhuDingin, kelembabanNormal), amoniaCukup);
      double r4 = min(min(suhuDingin, kelembabanNormal), amoniaBerlebih);
      double r5 = min(min(suhuDingin, kelembabanRendah), amoniaCukup);
      double r6 = min(min(suhuDingin, kelembabanRendah), amoniaBerlebih);
      double r7 = min(min(suhuPanas, kelembabanTinggi), amoniaCukup);
      double r8 = min(min(suhuPanas, kelembabanTinggi), amoniaBerlebih);
      double r9 = min(min(suhuPanas, kelembabanNormal), amoniaCukup);
      double r10 = min(min(suhuPanas, kelembabanNormal), amoniaBerlebih);
      double r11 = min(min(suhuPanas, kelembabanRendah), amoniaCukup);
      double r12 = min(min(suhuPanas, kelembabanRendah), amoniaBerlebih);
      double r13 = min(min(suhuNormal, kelembabanTinggi), amoniaCukup);
      double r14 = min(min(suhuNormal, kelembabanTinggi), amoniaBerlebih);
      double r15 = min(min(suhuNormal, kelembabanNormal), amoniaCukup);
      double r16 = min(min(suhuNormal, kelembabanNormal), amoniaBerlebih);
      double r17 = min(min(suhuNormal, kelembabanRendah), amoniaCukup);
      double r18 = min(min(suhuNormal, kelembabanRendah), amoniaBerlebih);

      //komposisi aturan
      //blower tambah
      List<double> ruleBlowerTambah = [
        r2,
        r4,
        r6,
        r7,
        r8,
        r9,
        r10,
        r11,
        r12,
        r14,
        r16,
        r18
      ];
      double blowerTambah = ruleBlowerTambah.reduce(
          (maxValue, current) => maxValue > current ? maxValue : current);
      //blower kurang
      List<double> ruleBlowerkurang = [r1, r3, r5, r13, r15, r17];
      double blowerkurang = ruleBlowerkurang.reduce(
          (maxValue, current) => maxValue > current ? maxValue : current);
      //heater nyala
      List<double> ruleHeaterNyala = [r1, r2, r3, r4, r5, r6];
      double heaterNyala = ruleHeaterNyala.reduce(
          (maxValue, current) => maxValue > current ? maxValue : current);
      //heater mati
      List<double> ruleHeaterMati = [
        r7,
        r8,
        r9,
        r10,
        r11,
        r12,
        r13,
        r14,
        r15,
        r16,
        r17,
        r18
      ];
      double heaterMati = ruleHeaterMati.reduce(
          (maxValue, current) => maxValue > current ? maxValue : current);
      //cooling pad nyala
      List<double> ruleCPNyala = [r5, r6, r11, r12, r17, r18];
      double cpNyala = ruleCPNyala.reduce(
          (maxValue, current) => maxValue > current ? maxValue : current);
      //Cooling pad mati
      List<double> ruleCPMati = [
        r1,
        r2,
        r3,
        r4,
        r7,
        r8,
        r9,
        r10,
        r13,
        r14,
        r15,
        r16
      ];
      double cpMati = ruleCPMati.reduce(
          (maxValue, current) => maxValue > current ? maxValue : current);

      // Defuzzifikasi (gunakan metode MOM - Mean Of Maximum)
      double zblower = ((blowerTambah * 75) + (blowerkurang * 25)) /
          (blowerTambah + blowerkurang);
      double zheater =
          ((heaterNyala * 75) + (heaterMati * 25)) / (heaterNyala + heaterMati);
      double zcoolPad = ((cpNyala * 75) + (cpMati * 25)) / (cpNyala + cpMati);

      //Hasil solusi crisp
      setState(() {
        if (zblower > 50) {
          hasilAksi += "Blower Tambah, ";
        } else {
          hasilAksi += "blower kurang, ";
        }

        if (zheater > 50) {
          hasilAksi += "heater Nyala, ";
        } else {
          hasilAksi += "heater mati, ";
        }

        if (zcoolPad > 50) {
          hasilAksi += "cooling Pad Nyala";
        } else {
          hasilAksi += "cooling Pad mati";
        }
        Map<String, String> newData = {
          "hasil": hasilAksi,
        };
        hasilAksiList.add(newData);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Panggil _getSensor() pada awal initState
    _getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Riwayat Monitoring",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: const Color.fromRGBO(255, 171, 0, 1),
      ),
      drawer: const DrawerContentAdm(),
      body: ListView.builder(
          itemCount: _listData.length,
          itemBuilder: ((context, index) {
            return Card(
              child: ListTile(
                title: Text("Suhu             : " +
                    _listData[index]['suhu'].toString() +
                    "\nKelembaban : " +
                    _listData[index]['kelembaban'].toString() +
                    "\nAmonia        : " +
                    _listData[index]['ammonia'].toString()),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Waktu : " + _listData[index]['created_at'].toString(),
                    ),
                    // Display hasilAksi for each data point
                    Text(
                        "Aksi: ${hasilAksiList.length > index ? hasilAksiList[index]['hasil'] : ''}"),
                  ],
                ),
              ),
            );
          })),
    );
  }
}
