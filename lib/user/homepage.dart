// ignore_for_file: avoid_print, non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sekolahmobile/logout.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeUser extends StatefulWidget {
  const HomeUser({super.key});

  @override
  State<HomeUser> createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  // Loading
  bool _isloading = true;
  
  // Mengambil Data
  List<dynamic> _listdata = [];
  
  // Api Mengambil Data
  Future<void> _mengambil_data() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.1.7/tutorial_api_php_flutter/Api/read.php"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _listdata = data; // Var Listdata
          _isloading = false; // Var Loading
          _pengguna_saat_ini; // Var Pengguna Yang Login (Profil)
        });
      }
    } catch (e) {
      print(e);
    }
  }

  // Search Data
  TextEditingController search = TextEditingController();
  List<dynamic> _results = [];
  
  // Api Search Data
  Future<void> _search(String query) async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.1.7/tutorial_api_php_flutter/Api/search.php?query=$query"),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _results = data;
        });
      }
    } catch (e) {
      setState(() {
        _results = [];
      });
      print('Error: $e');
    }
  }

  // Mengambil Data Yang Login (Profil)
  Map<String, dynamic> _pengguna_saat_ini = {};
  
  // Api Profil
  Future<void> _pengguna_sudah_login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.containsKey('id') && prefs.containsKey('username') && prefs.containsKey('password');
    if (isLoggedIn) {
      setState(() {
        _pengguna_saat_ini = {
          'id': prefs.getString('id'),
          'nama': prefs.getString('nama'),
          'kelas': prefs.getString('kelas'),
          'jurusan': prefs.getString('jurusan'),
          'image': prefs.getString('image'),
        };
      });
    } else {
      print('Anda Harus Login Terlebih Dahulu');
    }
  }

  @override
  void initState() {
    _mengambil_data();
    _pengguna_sudah_login();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home User",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'Profil',
                  child: const Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 10),
                      Text("Profil"),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Close",
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                        title: const Text("Profil"),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: _pengguna_saat_ini["image"] != null && _pengguna_saat_ini["image"].isNotEmpty
                                    ? ClipOval(
                                        child: Image.network("http://192.168.1.7/tutorial_api_php_flutter/Api/upload/${_pengguna_saat_ini['image']}",
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                        ),
                                      )
                                    : Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(100),
                                          color: Colors.grey,
                                        ),
                                        child: const Icon(Icons.person, color: Colors.white),
                                      ),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: Text(_pengguna_saat_ini['nama'],
                                  style: const TextStyle(
                                    fontSize: 25,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  const Text("Kelas : ",
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(_pengguna_saat_ini['kelas'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text("Jurusan : ",
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(_pengguna_saat_ini['jurusan'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                PopupMenuItem(
                  value: 'Logout',
                  child: const Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 10),
                      Text("Logout"),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Logout(),
                      ),
                    );
                  },
                ),
              ];
            },
            icon: const Icon(Icons.menu, color: Colors.white),
          ),
        ],
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: _isloading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  TextFormField(
                    controller: search,
                    decoration: InputDecoration(
                      labelText: "Search",
                      suffixIcon: IconButton(
                        onPressed: () => _search(search.text),
                        icon: const Icon(Icons.search),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _results.isNotEmpty ? _results.length : _listdata.length,
                      itemBuilder: (context, index) {
                        final item = _results.isNotEmpty
                            ? _results[index] as Map<String, dynamic>
                            : _listdata[index] as Map<String, dynamic>;
                        return Card(
                          child: ListTile(
                            subtitle: Row(
                              children: [
                                item["image"] != null && item["image"].isNotEmpty
                                    ? ClipOval(
                                        child: Image.network("http://192.168.1.7/tutorial_api_php_flutter/Api/upload/${item['image']}",
                                          fit: BoxFit.cover,
                                          width: 50,
                                          height: 50,
                                        ),
                                      )
                                    : Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(100),
                                          color: Colors.grey,
                                        ),
                                        child: const Icon(Icons.person, color: Colors.white),
                                      ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['nama']),
                              Text(item['kelas']),
                              Text(item['jurusan']),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
