import 'package:flutter/material.dart';
import 'package:mypethub/firebase/database.dart';

class AdoptionReportScreen extends StatefulWidget {
  final String userId;
  final String petId;

  AdoptionReportScreen({required this.userId, required this.petId});

  @override
  _AdoptionReportScreenState createState() => _AdoptionReportScreenState();
}

class _AdoptionReportScreenState extends State<AdoptionReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final Database _database = Database(); // Instancia de la clase Database

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final String phone = _phoneController.text;
      final String email = _emailController.text;
      final String description = _descriptionController.text;

      // Crear el mapa de datos para Firebase
      Map<String, dynamic> adoptionPetData = {
        'userId': widget.userId,
        'petId': widget.petId,
        'contactInfo': {
          'phone': phone,
          'email': email,
        },
        'description': description,
        'timestamp': DateTime.now().toIso8601String(), // Fecha y hora del registro
      };

      // Llamar al método reportAdoptionPet
      bool success = await _database.reportAdoptionPet(adoptionPetData);

      // Mostrar un mensaje al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Se ha publicado tu mascota en Adopción'
              : 'Error al enviar la información.'),
        ),
      );

      // Si se envió correctamente, reiniciar el formulario
      if (success) {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Formulario de Adopción', style: theme.textTheme.titleLarge),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Teléfono de contacto',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Por favor, ingresa un teléfono.' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Por favor, ingresa un correo electrónico.' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Por favor, proporciona una descripción.' : null,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: Color.fromARGB(255, 222, 49, 99),
                  foregroundColor: Colors.white,
                ),
                child: Text('Dar en Adopción', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
