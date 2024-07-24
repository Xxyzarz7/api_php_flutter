// ignore_for_file: unused_import, avoid_print, deprecated_member_use, non_constant_identifier_names

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Http
import 'package:sekolahmobile/admin/editdata.dart';
import 'package:sekolahmobile/login.dart';
import 'package:sekolahmobile/logout.dart';
import 'package:image_picker/image_picker.dart'; // Image Http
// Pdf Http
import 'package:path_provider/path_provider.dart'; 
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  
  //Loading
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

 // Api Menghapus Data
  Future<bool> _hapus(String id) async {
    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.7/tutorial_api_php_flutter/Api/hapus.php"),
        body: {"id": id},
      );
      if (response.statusCode == 200) {
        _mengambil_data(); // Var Mengambil Data
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Menambah Data
  final formKey = GlobalKey<FormState>();
  TextEditingController nama = TextEditingController();
  TextEditingController kelas = TextEditingController();
  TextEditingController jurusan = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController role = TextEditingController();
  // Tambah Image
  File? _image;
  final picker = ImagePicker();
  // Api Menambah Data
  Future<bool> _simpan() async {
    final uri = Uri.parse("http://192.168.1.7/tutorial_api_php_flutter/Api/create.php");
    var request = http.MultipartRequest('POST', uri);
    request.fields['nama'] = nama.text;
    request.fields['kelas'] = kelas.text;
    request.fields['jurusan'] = jurusan.text;
    request.fields['username'] = username.text;
    request.fields['password'] = password.text;
    request.fields['role'] = role.text;
    if (_image != null) {
      var pic = await http.MultipartFile.fromPath("image", _image!.path);
      request.files.add(pic);
    }
    var response = await request.send();
    return response.statusCode == 200;
  }

  // Memilih Image
  Future<void> _pilih_image() async {
    final pickerImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickerImage != null) {
      setState(() {
        _image = File(pickerImage.path);
      });
    }
  }

  // Api Pdf
  Future<List> _mengambil_data_pdf() async {
    try {
      final response = await http.get(Uri.parse("http://192.168.1.7/tutorial_api_php_flutter/Api/read.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      }
    } catch (e) {
      print(e);
    }
    return [];
  }

  Future<void> _menghasilkan_pdf() async {
    final pdfData = await _mengambil_data_pdf();
    final pdf = pw.Document();
    final tableHeaders = ['Nama', 'Kelas', 'Jurusan']; // Nama Judul Dari Tabel Pdf
    final tableData = pdfData.map(
      (item) => [item['nama'], item['kelas'], item['jurusan']], // Isi Dari Pdf
    ).toList();
    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Table.fromTextArray(
            context: context, 
            data: [tableHeaders, ...tableData],
          ),
        ],
      ),
    );
    final output = await getExternalStorageDirectory();
    final file = File("${output!.path}/laporan_siswa.pdf");
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);
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
        title: const Text("Home Admin",
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
                                  const Text( "Kelas : ",
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
                  value: 'File',
                  onTap: _menghasilkan_pdf,
                  child: const Row(
                    children: [
                      Icon(Icons.file_copy),
                      SizedBox(width: 10),
                      Text("File"),
                    ],
                  ),
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
                      itemCount: _results.isNotEmpty
                          ? _results.length
                          : _listdata.length,
                      itemBuilder: (context, index) { final item = _results.isNotEmpty
                            ? _results[index] as Map<String, dynamic>
                            : _listdata[index] as Map<String, dynamic>;
                        return Card(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditDataPage(
                                    ListData: {
                                      "id": item['id'],
                                      "nama": item['nama'],
                                      "kelas": item['kelas'],
                                      "jurusan": item['jurusan'],
                                      "username": item['username'],
                                      "password": item['password'],
                                      "role": item['role'],
                                    },
                                  ),
                                ),
                              );
                            },
                            child: ListTile(
                              trailing: IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        content: const Text("Apakah Anda Yakin Ingin Menghapus Data Ini ?"),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () {
                                              _hapus(item['id']).then((value) {
                                                if (value) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text("Data berhasil dihapus"),
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text("Gagal menghapus data"),
                                                    ),
                                                  );
                                                }
                                                Navigator.pop(context);
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                            ),
                                            child: const Text("Delete"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                            ),
                                            child: const Text("Close"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.delete),
                              ),
                              subtitle: Row(
                                children: [
                                  item["image"] != null && item["image"].isNotEmpty
                                      ? ClipOval(
                                          child: Image.network('http://192.168.1.7/tutorial_api_php_flutter/Api/upload/${item['image']}',
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
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
              title: const Text("Tambah Data"),
              content: SingleChildScrollView(
                child: Center(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nama,
                          decoration: const InputDecoration(
                            labelText: 'Nama',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "nama tidak boleh kosong";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: kelas,
                          decoration: const InputDecoration(
                            labelText: 'Kelas',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "kelas tidak boleh kosong";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: jurusan,
                          decoration: const InputDecoration(
                            labelText: 'Jurusan',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "jurusan tidak boleh kosong";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: username,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "username tidak boleh kosong";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: password,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "password tidak boleh kosong";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: role,
                          decoration: const InputDecoration(
                            labelText: 'Role',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Role tidak boleh kosong";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _pilih_image();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Text("Upload Image",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        _image == null
                            ? const Text("Image Belum Di Pilih")
                            : const Text("Image Sudah Di Pilih"),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                _simpan().then((value) {
                                  if (value) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Data berhasil ditambahkan"),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Gagal menambahkan data"),
                                      ),
                                    );
                                  }
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomeAdmin(),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Text("Konfirmasi",
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
              ),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}