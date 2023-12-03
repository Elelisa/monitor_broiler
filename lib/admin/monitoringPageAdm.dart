import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:monitor_broiler/admin/addPeternak.dart';
import 'package:monitor_broiler/admin/dataPtkPage.dart';
import 'package:monitor_broiler/admin/riwayatDataPage.dart';
import 'package:monitor_broiler/landingPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:monitor_broiler/peternak/monitoringPagePtk.dart';

class MonitoringPageAdmin extends StatefulWidget {
  const MonitoringPageAdmin({super.key});

  @override
  State<MonitoringPageAdmin> createState() => _MonitoringPageAdminState();
}

class _MonitoringPageAdminState extends State<MonitoringPageAdmin> {
  double zblower = 0.0;
  double zheater = 0.0;
  double zcoolPad = 0.0;
  double suhu = 0.0;
  double kelembaban = 0.0;
  double ammonia = 0.0;
  var hasilAksi = '';
  late Timer _timer;
  String timeStamp = "";

  Future _getSensor() async {
    try {
      String url = "https://apkmonitoring.bantuas.online/getdata_kandang.php";
      //String url = "http://192.168.75.99/monitoring_api/getdata_kandang.php";
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print("masuk");
        print(response.body);
        final data = jsonDecode(response.body);
        String ctValue = data["m2m:cin"]["ct"];
        DateTime createdAt = DateTime(
          int.parse(ctValue.substring(0, 4)), // Tahun
          int.parse(ctValue.substring(4, 6)), // Bulan
          int.parse(ctValue.substring(6, 8)), // Hari
          int.parse(ctValue.substring(9, 11)) + 1, // Jam
          int.parse(ctValue.substring(11, 13)), // Menit
          int.parse(ctValue.substring(13, 15)), // Detik
        );

        if (data.containsKey("m2m:cin")) {
          final conData = jsonDecode(data["m2m:cin"]["con"]);

          if (conData.containsKey("temperature") &&
              conData.containsKey("humidity") &&
              conData.containsKey("amonia")) {
            double? temperature = conData["temperature"] is int
                ? (conData["temperature"] as int).toDouble()
                : conData["temperature"] as double?;

            double? humidity = conData["humidity"] is int
                ? (conData["humidity"] as int).toDouble()
                : conData["humidity"] as double?;

            double? amonia = conData["amonia"] is int
                ? (conData["amonia"] as int).toDouble()
                : conData["amonia"] as double?;

            if (temperature != null && humidity != null && amonia != null) {
              setState(() {
                // Use the non-null values as needed

                suhu = temperature;
                kelembaban = humidity;
                ammonia = amonia;
                timeStamp = "$createdAt";
                hitungAksi();
              });
            } else {
              print("One or more values are null.");
            }
          } else {
            print("One or more keys are missing in the JSON response.");
          }
        }
      }
    } catch (e) {
      print("gagal");
      print(e);
    }
  }

  Future<void> hitungAksi() async {
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
    double blowerTambah = ruleBlowerTambah
        .reduce((maxValue, current) => maxValue > current ? maxValue : current);
    //blower kurang
    List<double> ruleBlowerkurang = [r1, r3, r5, r13, r15, r17];
    double blowerkurang = ruleBlowerkurang
        .reduce((maxValue, current) => maxValue > current ? maxValue : current);
    //heater nyala
    List<double> ruleHeaterNyala = [r1, r2, r3, r4, r5, r6];
    double heaterNyala = ruleHeaterNyala
        .reduce((maxValue, current) => maxValue > current ? maxValue : current);
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
    double heaterMati = ruleHeaterMati
        .reduce((maxValue, current) => maxValue > current ? maxValue : current);
    //cooling pad nyala
    List<double> ruleCPNyala = [r5, r6, r11, r12, r17, r18];
    double cpNyala = ruleCPNyala
        .reduce((maxValue, current) => maxValue > current ? maxValue : current);
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
    double cpMati = ruleCPMati
        .reduce((maxValue, current) => maxValue > current ? maxValue : current);

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
    });
  }

  Future<void> _insertSensor() async {
    try {
      var res = await http.post(
        Uri.parse(
            "https://apkmonitoring.bantuas.online/insertdata_kandang.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "suhu": suhu,
          "kelembaban": kelembaban,
          "amonia": ammonia,
        }),
      );
      if (res.statusCode == 200) {
        var response = json.decode(res.body);
        if (response["success"] == "true") {
          print("Data Inserted");
        } else {
          print("Error: ${response['error']}");
        }
      } else {
        print("Failed to send data to server.");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    // Panggil _getSensor() pada awal initState
    _getSensor();
    // Set timer untuk memanggil _getSensor() dan _insertSensor() setiap 5 menit (misalnya)
    _timer = Timer.periodic(Duration(minutes: 5), (Timer timer) {
      _getSensor();
      hasilAksi = '';
      _insertSensor();
    });
  }

  @override
  void dispose() {
    // Cancel timers or dispose of any subscriptions here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var lebarMedia = MediaQuery.of(context).size.width;
    var tinggiMedia = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Monitoring Kandang",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.amberAccent[700],
      ),
      drawer: const DrawerContentAdm(),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              height: tinggiMedia - 10,
              width: lebarMedia - 10,
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 226, 226, 226)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        "Diperbarui : $timeStamp",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    VarContainer(variabel: "Suhu", nilai: suhu),
                    VarContainer(variabel: "Kelembaban", nilai: kelembaban),
                    VarContainer(variabel: "Amonia", nilai: ammonia),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: Container(
                        width: lebarMedia,
                        height: 150,
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 42, 103, 37)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            "Aksi : $hasilAksi",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DrawerContentAdm extends StatelessWidget {
  const DrawerContentAdm({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 255, 207, 110),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.amberAccent[700],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      image: const DecorationImage(
                        image: AssetImage("assets/broiler1.png"),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      "Kandang Bantuas",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              )),
          DrawerList(
              listTitle: "Monitoring Kandang",
              rute: (context) => const MonitoringPageAdmin()),
          DrawerList(
              listTitle: "Data Peternak",
              rute: (context) => const DataPtkPage()),
          DrawerList(
              listTitle: "Buat Akun Peternak",
              rute: (context) => const AddPeternak()),
          DrawerList(
              listTitle: "Riwayat Monitoring Kandang",
              rute: (context) => Riwayat()),
          DrawerList(
              listTitle: "Keluar", rute: (context) => const LandingPage()),
        ],
      ),
    );
  }
}
