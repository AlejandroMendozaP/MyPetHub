import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  String? _profileImageUrl;
  XFile? _newProfileImage; // Imagen temporal seleccionada
  String? _newProfileImageUrl; // URL pública de la nueva imagen
  List<String> _allInterests = [];
  List<String> _selectedInterests = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadInterests();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!docSnapshot.exists) return;

      final userData = docSnapshot.data()!;
      setState(() {
        _nameController.text = userData['name'] ?? '';
        _phoneController.text = userData['phone'] ?? '';
        _cityController.text = userData['city'] ?? '';
        _stateController.text = userData['state'] ?? '';
        _profileImageUrl = userData['photo'];
        _selectedInterests = List<String>.from(userData['interests'] ?? []);
      });
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  Future<void> _loadInterests() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('intereses').get();
      final interests =
          querySnapshot.docs.map((doc) => doc['interes'] as String).toList();

      setState(() {
        _allInterests = interests;
      });
    } catch (e) {
      print("Error loading interests: $e");
    }
  }

  Future<void> _selectPhoto() async {
    final picker = ImagePicker();

    // Mostrar opciones de selección
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
                Navigator.of(context).pop(); // Cierra el modal

                // Retrasar la ejecución para garantizar que el contexto sea válido
                await Future.delayed(Duration(milliseconds: 100));

                final XFile? pickedImage = await picker.pickImage(
                  source: ImageSource.camera,
                );

                if (pickedImage != null) {
                  setState(() {
                    _newProfileImage = pickedImage;
                  });

                  // Mostrar SnackBar en un contexto válido
                  if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Foto tomada. Guarde los cambios para actualizar.')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Seleccionar de la galería'),
              onTap: () async {
                Navigator.of(context).pop(); // Cierra el modal

                // Retrasar la ejecución para garantizar que el contexto sea válido
                await Future.delayed(Duration(milliseconds: 100));

                final XFile? pickedImage = await picker.pickImage(
                  source: ImageSource.gallery,
                );

                if (pickedImage != null) {
                  setState(() {
                    _newProfileImage = pickedImage;
                  });

                  // Mostrar SnackBar en un contexto válido
                  if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Imagen seleccionada. Guarde los cambios para actualizar.')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        // Subir imagen a Supabase si hay una nueva imagen seleccionada
        if (_newProfileImage != null) {
          try {
            final supabaseClient = Supabase.instance.client;
            final fileBytes = await _newProfileImage!.readAsBytes();

            final filePath =
                'users/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
            await supabaseClient.storage
                .from('mypethub')
                .uploadBinary(filePath, fileBytes);

            // Obtener URL pública
            _newProfileImageUrl =
                supabaseClient.storage.from('mypethub').getPublicUrl(filePath);
            Navigator.pop(context);
          } catch (e) {
            print("Error al subir la imagen: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al subir la imagen')),
            );
            return;
          }
        }

        // Actualizar datos en Firebase
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'interests': _selectedInterests,
          if (_newProfileImageUrl != null) 'photo': _newProfileImageUrl,
        });

        // Actualizar estado local
        if (_newProfileImageUrl != null) {
          setState(() {
            _profileImageUrl = _newProfileImageUrl;
            _newProfileImage = null;
            _newProfileImageUrl = null;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil actualizado exitosamente')),
        );
      } catch (e) {
        print("Error al guardar el perfil: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el perfil')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Editar Perfil',
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
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _newProfileImage != null
                          ? FileImage(File(_newProfileImage!.path))
                          : (_profileImageUrl != null
                                  ? NetworkImage(_profileImageUrl!)
                                  : AssetImage('assets/default_avatar.jpg'))
                              as ImageProvider,
                      backgroundColor: Colors.grey[300],
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: GestureDetector(
                        onTap: _selectPhoto,
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          child: Icon(Icons.camera_alt,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
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
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty
                    ? 'Este campo es obligatorio'
                    : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Ciudad',
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
                controller: _stateController,
                decoration: InputDecoration(
                  labelText: 'Estado',
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
              SizedBox(height: 20),
              Text(
                'Intereses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _allInterests.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allInterests.map((interest) {
                        final isSelected =
                            _selectedInterests.contains(interest);
                        return ChoiceChip(
                          label: Text(
                            interest,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Colors.blue,
                          backgroundColor: Colors.grey.shade300,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _selectedInterests.add(interest);
                              } else {
                                _selectedInterests.remove(interest);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text('Guardar Cambios', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
