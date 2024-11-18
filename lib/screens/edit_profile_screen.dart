import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

      final docSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
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
      final querySnapshot = await FirebaseFirestore.instance.collection('intereses').get();
      final interests = querySnapshot.docs.map((doc) => doc['interes'] as String).toList();

      setState(() {
        _allInterests = interests;
      });
    } catch (e) {
      print("Error loading interests: $e");
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'interests': _selectedInterests,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil actualizado exitosamente')),
        );
      } catch (e) {
        print("Error saving profile: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el perfil')),
        );
      }
    }
  }

  void _selectPhoto() {
    print("Seleccionar foto de perfil");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Editar Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : AssetImage('assets/default_avatar.jpg') as ImageProvider,
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
                          child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
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
                        final isSelected = _selectedInterests.contains(interest);
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
