import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:monitorairlaut/widgets/card_form.dart';

class AddCardPage extends StatefulWidget {
  final bool isEdit;
  final String? sensorKey;
  final String? nama;
  final String? deskripsi;
  final String? cardid;

  const AddCardPage({
    this.isEdit = false,
    this.sensorKey,
    this.nama,
    this.deskripsi,
    this.cardid,
  });

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  List<String> _sensorKeys = [];
  String? _selectedSensor;
  bool _loadingSensors = true;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _nameController.text = widget.nama ?? '';
      _descController.text = widget.deskripsi ?? '';
      _selectedSensor = widget.sensorKey;
    }
    _fetchSensorKeys();
  }

  Future<void> _fetchSensorKeys() async {
    try {
      final snapshot = await _database.get();
      if (!mounted) return;

      if (snapshot.exists) {
        final keys =
            snapshot.children.map((child) => child.key ?? 'Unknown').toList();
        setState(() {
          _sensorKeys = keys;
          _loadingSensors = false;
        });
      } else {
        setState(() {
          _sensorKeys = [];
          _loadingSensors = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sensorKeys = [];
        _loadingSensors = false;
      });
    }
  }

  Future<void> _saveCard() async {
    final nama = _nameController.text.trim();
    final deskripsi = _descController.text.trim();

    if (nama.isEmpty || deskripsi.isEmpty || _selectedSensor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua field harus diisi')),
      );
      return;
    }

    try {
      if (widget.isEdit) {
        await FirebaseFirestore.instance
            .collection('cards')
            .doc(widget.cardid)
            .update({
          'nama': nama,
          'deskripsi': deskripsi,
          'sensorKey': _selectedSensor,
        });
      } else {
        await FirebaseFirestore.instance.collection('cards').add({
          'nama': nama,
          'deskripsi': deskripsi,
          'sensorKey': _selectedSensor,
        });
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(widget.isEdit
                ? "Card berhasil diperbarui"
                : "Card berhasil ditambahkan")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit
            ? "Edit Titik Monitoring"
            : "Tambah Titik Monitoring"),
      ),
      body: _loadingSensors
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: CardForm(
                nameController: _nameController,
                descController: _descController,
                sensorKeys: _sensorKeys,
                selectedSensor: _selectedSensor,
                onSensorChanged: (value) {
                  setState(() {
                    _selectedSensor = value;
                  });
                },
                onSave: _saveCard,
              ),
            ),
    );
  }
}
