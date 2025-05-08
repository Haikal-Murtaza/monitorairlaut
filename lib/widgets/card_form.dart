import 'package:flutter/material.dart';

class CardForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descController;
  final List<String> sensorKeys;
  final String? selectedSensor;
  final Function(String?) onSensorChanged;
  final VoidCallback onSave;

  const CardForm({
    required this.nameController,
    required this.descController,
    required this.sensorKeys,
    required this.selectedSensor,
    required this.onSensorChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: 'Nama Card'),
        ),
        SizedBox(height: 10),
        TextField(
          controller: descController,
          decoration: InputDecoration(labelText: 'Deskripsi'),
        ),
        SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: selectedSensor,
          items: sensorKeys.map((sensor) {
            return DropdownMenuItem(
              value: sensor,
              child: Text(sensor),
            );
          }).toList(),
          onChanged: onSensorChanged,
          decoration: InputDecoration(labelText: 'Pilih Sensor'),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: onSave,
          child: Text('Simpan'),
        ),
      ],
    );
  }
}
