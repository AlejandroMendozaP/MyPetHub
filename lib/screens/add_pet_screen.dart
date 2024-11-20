import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class AddPetScreen extends StatefulWidget {
  @override
  _AddPetScreenState createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _raceController = TextEditingController();
  final _colorController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedSex;
  DateTime? _birthdate;
  XFile? _petImage;
  String? _petImageUrl;

  final List<String> _sexOptions = ['Macho', 'Hembra'];

  Future<void> _selectPhoto() async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Tomar una foto'),
              onTap: () async {
                Navigator.of(context).pop();
                final XFile? pickedImage =
                    await picker.pickImage(source: ImageSource.camera);
                if (pickedImage != null) {
                  setState(() {
                    _petImage = pickedImage;
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Seleccionar de la galería'),
              onTap: () async {
                Navigator.of(context).pop();
                final XFile? pickedImage =
                    await picker.pickImage(source: ImageSource.gallery);
                if (pickedImage != null) {
                  setState(() {
                    _petImage = pickedImage;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadPhoto() async {
    if (_petImage == null) return;

    try {
      final supabaseClient = Supabase.instance.client;
      final fileBytes = await _petImage!.readAsBytes();
      final filePath =
          'pets/${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabaseClient.storage
          .from('mypethub')
          .uploadBinary(filePath, fileBytes);

      // Obtener URL pública
      final publicUrl =
          supabaseClient.storage.from('mypethub').getPublicUrl(filePath);

      setState(() {
        _petImageUrl = publicUrl;
      });
    } catch (e) {
      print("Error al subir la imagen: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir la imagen')),
      );
    }
  }

  Future<void> _savePet() async {
    if (_formKey.currentState!.validate() &&
        _birthdate != null &&
        _selectedSex != null) {
      String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

      await _uploadPhoto(); // Subir foto antes de guardar los datos

      try {
        await FirebaseFirestore.instance.collection('pets').add({
          'name': _nameController.text,
          'race': _raceController.text,
          'sex': _selectedSex,
          'color': _colorController.text,
          'description': _descriptionController.text,
          'birthdate': _birthdate,
          'userid': '/users/$currentUid',
          if (_petImageUrl != null) 'photo': _petImageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Mascota registrada exitosamente")),
        );

        Navigator.pop(context);
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Agregar Mascota',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _selectPhoto,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _petImage != null
                      ? FileImage(File(_petImage!.path))
                      : AssetImage('assets/default_pet.jpg') as ImageProvider,
                  backgroundColor: Colors.grey[300],
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Este campo es obligatorio'
                    : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _raceController,
                decoration: InputDecoration(
                  labelText: 'Raza',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Este campo es obligatorio'
                    : null,
              ),
              SizedBox(height: 15),
              DropdownButtonFormField2(
                decoration: InputDecoration(
                  labelText: 'Sexo',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                isExpanded: true,
                items: _sexOptions
                    .map((sex) => DropdownMenuItem<String>(
                          value: sex,
                          child: Text(sex),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSex = value as String?;
                  });
                },
                validator: (value) =>
                    value == null ? 'Por favor, selecciona un sexo' : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _colorController,
                decoration: InputDecoration(
                  labelText: 'Color',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Este campo es obligatorio'
                    : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 5,
                validator: (value) => value == null || value.isEmpty
                    ? 'Este campo es obligatorio'
                    : null,
              ),
              SizedBox(height: 15),
              GestureDetector(
                onTap: () async {
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
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _birthdate != null
                            ? "Fecha de Nacimiento: ${_birthdate!.toLocal().toString().split(' ')[0]}"
                            : 'Seleccionar Fecha de Nacimiento',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Icon(Icons.calendar_today, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _savePet,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: Color.fromARGB(255, 222, 49, 99),
                  foregroundColor: Colors.white,
                ),
                child:
                    Text('Registrar Mascota', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
