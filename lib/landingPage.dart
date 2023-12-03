import 'package:flutter/material.dart';
import 'package:monitor_broiler/admin/loginAdmin.dart';
import 'package:monitor_broiler/peternak/loginPeternak.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Broiler Bantuas"),
        ),
        backgroundColor: Colors.amberAccent[700],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "Selamat datang di aplikasi monitoring kandang broiler Bantuas!\nSilahkan pilih role untuk login.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AktorButton(
                gambar: "assets/profile.png",
                aktor: "Admin",
                rute: (context) => const LoginPageAdmin(),
              ),
              AktorButton(
                gambar: "assets/profile2.png",
                aktor: "Peternak",
                rute: (context) => LoginPagePeternak(),
              )
            ],
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
    );
  }
}

class AktorButton extends StatelessWidget {
  const AktorButton(
      {super.key,
      required this.gambar,
      required this.aktor,
      required this.rute});

  final String gambar;
  final String aktor;
  final Widget Function(BuildContext) rute;

  @override
  Widget build(BuildContext context) {
    var lebarMedia = MediaQuery.of(context).size.width;
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          height: 120,
          width: (lebarMedia / 2) - 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage(gambar),
            ),
          ),
          child: TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: rute));
            },
            child: const Text(""),
          ),
        ),
      ),
      Container(
        height: 50,
        width: (lebarMedia / 2) - 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: rute));
            },
            child: Text(aktor)),
      )
    ]);
  }
}
