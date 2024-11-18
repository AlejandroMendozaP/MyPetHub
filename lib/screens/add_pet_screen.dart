import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPetScreen extends StatefulWidget {
  @override
  _AddPetScreenState createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _raceController = TextEditingController();
  final _sexController = TextEditingController();
  final _colorController = TextEditingController();
  DateTime? _birthdate;

  void _savePet() async {
    if (_formKey.currentState!.validate() && _birthdate != null) {
      String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

      try {
        await FirebaseFirestore.instance.collection('pets').add({
          'name': _nameController.text,
          'race': _raceController.text,
          'sex': _sexController.text,
          'color': _colorController.text,
          'birthdate': _birthdate,
          'userid': '/users/$currentUid', // Relaciona con el usuario actual
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Mascota registrada exitosamente")),
        );

        Navigator.pop(context); // Regresa a la pantalla anterior
      } catch (e) {
        print("Error al guardar la mascota: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al registrar la mascota")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, completa todos los campos")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Mascota'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Nombre"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingresa el nombre";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _raceController,
                decoration: InputDecoration(labelText: "Raza"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingresa la raza";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _sexController,
                decoration: InputDecoration(labelText: "Sexo"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingresa el sexo";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _colorController,
                decoration: InputDecoration(labelText: "Color"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingresa el color";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Text("Fecha de Nacimiento: ${_birthdate != null ? _birthdate!.toLocal().toString().split(' ')[0] : 'No seleccionada'}"),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _birthdate = pickedDate;
                    });
                  }
                },
                child: Text("Seleccionar Fecha"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePet,
                child: Text("Registrar Mascota"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
