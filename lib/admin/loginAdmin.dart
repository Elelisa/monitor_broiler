import 'package:flutter/material.dart';
import 'package:monitor_broiler/admin/monitoringPageAdm.dart';

class LoginPageAdmin extends StatelessWidget {
  const LoginPageAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Login Admin"),
        ),
        backgroundColor: Colors.amberAccent[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: LoginFormAdmin(),
    );
  }
}

class LoginFormAdmin extends StatefulWidget {
  const LoginFormAdmin({super.key});

  @override
  _LoginFormAdminState createState() => _LoginFormAdminState();
}

class _LoginFormAdminState extends State<LoginFormAdmin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username == 'admin_bantuas' && password == 'broiler123') {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => MonitoringPageAdmin()));
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Login Failed'),
            content: const Text('Invalid username or password.'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
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
                controller: _usernameController,
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
                controller: _passwordController,
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
              child: const Text('Login'),
            ),
          ],
        ),
      ],
    );
  }
}
