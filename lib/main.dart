import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warnet Billing App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[200], // Light grey background
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          ),
        ),
      ),
      home: const BillingForm(),
    );
  }
}

class BillingForm extends StatefulWidget {
  const BillingForm({Key? key}) : super(key: key);

  @override
  _BillingFormState createState() => _BillingFormState();
}

class _BillingFormState extends State<BillingForm> {
  final _formKey = GlobalKey<FormState>();
  final _kodePelangganController = TextEditingController();
  final _namaPelangganController = TextEditingController();
  String? _jenisPelanggan;
  DateTime? _selectedDate;
  TimeOfDay? _jamMasuk;
  TimeOfDay? _jamKeluar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Entri Biaya Warnet'),
      ),
      body: Stack(
        children: [
          // Background image or color
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg_image.jpg'), // Add your background image here
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _kodePelangganController,
                            decoration: const InputDecoration(labelText: 'Kode Pelanggan'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Masukkan kode pelanggan';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _namaPelangganController,
                            decoration: const InputDecoration(labelText: 'Nama Pelanggan'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Masukkan nama pelanggan';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _jenisPelanggan,
                            decoration: const InputDecoration(labelText: 'Jenis Pelanggan'),
                            items: const [
                              DropdownMenuItem(value: 'VIP', child: Text('VIP')),
                              DropdownMenuItem(value: 'GOLD', child: Text('GOLD')),
                              DropdownMenuItem(value: 'Regular', child: Text('Regular')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _jenisPelanggan = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Pilih jenis pelanggan';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: const InputDecoration(labelText: 'Tanggal Masuk'),
                                controller: TextEditingController(
                                  text: _selectedDate != null
                                      ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
                                      : '',
                                ),
                                validator: (value) {
                                  if (_selectedDate == null) {
                                    return 'Masukkan tanggal masuk';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => _selectJamMasuk(context),
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: const InputDecoration(labelText: 'Jam Masuk'),
                                controller: TextEditingController(
                                  text: _jamMasuk != null ? _jamMasuk!.format(context) : '',
                                ),
                                validator: (value) {
                                  if (_jamMasuk == null) {
                                    return 'Masukkan jam masuk';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => _selectJamKeluar(context),
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: const InputDecoration(labelText: 'Jam Keluar'),
                                controller: TextEditingController(
                                  text: _jamKeluar != null ? _jamKeluar!.format(context) : '',
                                ),
                                validator: (value) {
                                  if (_jamKeluar == null) {
                                    return 'Masukkan jam keluar';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _calculateBilling();
                              }
                            },
                            child: const Text('Hitung Biaya'),
                          ),
                        ],
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectJamMasuk(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _jamMasuk ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _jamMasuk) {
      setState(() {
        _jamMasuk = picked;
      });
    }
  }

  Future<void> _selectJamKeluar(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _jamKeluar ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _jamKeluar) {
      setState(() {
        _jamKeluar = picked;
      });
    }
  }

  void _calculateBilling() {
    int jamMasuk = _jamMasuk!.hour;
    int jamKeluar = _jamKeluar!.hour;
    int lama = jamKeluar - jamMasuk;
    double tarif = 10000;
    double totalBayar = lama * tarif;
    double diskon = 0;

    if (_jenisPelanggan == 'VIP' && lama > 2) {
      diskon = 0.02 * totalBayar;
    } else if (_jenisPelanggan == 'GOLD' && lama > 2) {
      diskon = 0.05 * totalBayar;
    }

    totalBayar -= diskon;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          kodePelanggan: _kodePelangganController.text,
          namaPelanggan: _namaPelangganController.text,
          jenisPelanggan: _jenisPelanggan!,
          tglMasuk: _selectedDate != null
              ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
              : '',
          jamMasuk: jamMasuk,
          jamKeluar: jamKeluar,
          lama: lama,
          tarif: tarif,
          diskon: diskon,
          totalBayar: totalBayar,
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final String kodePelanggan;
  final String namaPelanggan;
  final String jenisPelanggan;
  final String tglMasuk;
  final int jamMasuk;
  final int jamKeluar;
  final int lama;
  final double tarif;
  final double diskon;
  final double totalBayar;

  const ResultScreen({
    Key? key,
    required this.kodePelanggan,
    required this.namaPelanggan,
    required this.jenisPelanggan,
    required this.tglMasuk,
    required this.jamMasuk,
    required this.jamKeluar,
    required this.lama,
    required this.tarif,
    required this.diskon,
    required this.totalBayar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Perhitungan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Kode Pelanggan', kodePelanggan),
            _buildInfoRow('Nama Pelanggan', namaPelanggan),
            _buildInfoRow('Jenis Pelanggan', jenisPelanggan),
            _buildInfoRow('Tanggal Masuk', tglMasuk),
            _buildInfoRow('Jam Masuk', jamMasuk.toString().padLeft(2, '0') + ':00'),
            _buildInfoRow('Jam Keluar', jamKeluar.toString().padLeft(2, '0') + ':00'),
            _buildInfoRow('Lama Penggunaan', '$lama jam'),
            _buildInfoRow('Tarif per Jam', 'Rp ${tarif.toStringAsFixed(0)}'),
            _buildInfoRow('Diskon', 'Rp ${diskon.toStringAsFixed(0)}'),
            const Divider(thickness: 2),
            _buildInfoRow('Total Bayar', 'Rp ${totalBayar.toStringAsFixed(0)}', isTotal: true),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Kembali ke Form'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}