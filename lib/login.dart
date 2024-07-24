// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sekolahmobile/admin/homepage.dart';
import 'package:sekolahmobile/user/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  Future<void> login() async {
    if (username.text.isEmpty && password.text.isEmpty) { // Cek Apakah Username Dan Password Kosong
      ScaffoldMessenger.of(context).showSnackBar( // Untuk MemunculkanPesan Jika Kosong
        const SnackBar(
          content: Text("Tolong Masukkan Username Dan Password"), // Output Pesan (Yang Keluar Dari Aplikasi)
        ),
      );
      return;
    } else if (username.text.isEmpty) { // Jika Usernamenya Yang Kosong
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tolong Masukkan Username"),
        ),
      );
      return;
    } else if (password.text.isEmpty) { // Jika Passwordnya Yang Kosong
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tolong Masukkan Password"),
        ),
      );
      return;
    }

    var response = await http.post(
      Uri.parse("http://192.168.1.7/tutorial_api_php_flutter/Api/login.php"),
      body: {
        "username": username.text,
        "password": password.text,
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status'] == 'Success') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username.text);
        await prefs.setString('password', password.text);
        await prefs.setString('id', data['id']);
        await prefs.setString('image', data['image']);
        await prefs.setString('nama', data['nama']);
        await prefs.setString('kelas', data['kelas']);
        await prefs.setString('jurusan', data['jurusan']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Success'),
          ),
        );

        if (data['role'] == 'Admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeAdmin(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeUser(),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username atau password salah'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat melakukan login'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 243, 243, 1),
      body: Center(
        child: Container(
          width: 325,
          height: 375,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 24,
                offset: Offset(4, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text("Log in",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: username,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: password,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 35),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text("Log in",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}