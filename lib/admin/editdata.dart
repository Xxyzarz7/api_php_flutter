// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sekolahmobile/admin/homepage.dart';

class EditDataPage extends StatefulWidget {
  final Map ListData;

  const EditDataPage({super.key, required this.ListData});

  @override
  State<EditDataPage> createState() => _EditDataPageState();
}

class _EditDataPageState extends State<EditDataPage> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController id;
  late TextEditingController nama;
  late TextEditingController kelas;
  late TextEditingController jurusan;
  late TextEditingController username;
  late TextEditingController password;
  late TextEditingController role;

  @override
  void initState() {
    super.initState();
    id = TextEditingController(text: widget.ListData['id']);
    nama = TextEditingController(text: widget.ListData['nama']);
    kelas = TextEditingController(text: widget.ListData['kelas']);
    jurusan = TextEditingController(text: widget.ListData['jurusan']);
    username = TextEditingController(text: widget.ListData['username']);
    password = TextEditingController(text: widget.ListData['password']);
    role = TextEditingController(text: widget.ListData['role']);
  }

  Future<bool> _update() async {
    final response = await http.post(
      Uri.parse("http://192.168.1.7/tutorial_api_php_flutter/Api/edit.php"),
      body: {
        "id": id.text,
        "nama": nama.text,
        "kelas": kelas.text,
        "jurusan": jurusan.text,
        "username": username.text,
        "password": password.text,
        "role": role.text,
      },
    );
    return response.statusCode == 200;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Data",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  TextFormField(
                    controller: nama,
                    decoration: const InputDecoration(
                      labelText: "Nama",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Nama tidak boleh kosong";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: kelas,
                    decoration: const InputDecoration(
                      labelText: "Kelas",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Kelas tidak boleh kosong";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: jurusan,
                    decoration: const InputDecoration(
                      labelText: "Jurusan",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Jurusan tidak boleh kosong";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: username,
                    decoration: const InputDecoration(
                      labelText: "Username",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Username tidak boleh kosong";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: password,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Password tidak boleh kosong";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: role,
                    decoration: const InputDecoration(
                      labelText: "Role",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Role tidak boleh kosong";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          _update().then((value) {
                            if (value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Data berhasil diupdate'),
                                ),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeAdmin(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Gagal update data'),
                                ),
                              );
                            }
                          });
                        }
                      },
                      child: const Text(
                        "Update",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}