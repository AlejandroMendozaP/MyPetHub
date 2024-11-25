import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa Firestore para manejar streams
import 'package:mypethub/firebase/database.dart';
import 'package:mypethub/models/pet.dart';
import 'package:mypethub/screens/add_pet_screen.dart';
import 'package:mypethub/views/pet_widget.dart';

class MyPetsScreen extends StatefulWidget {
  @override
  _MyPetsScreenState createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  late String currentUid;
  late Database db;
  String selectedInterest = 'Todos'; // Inicializamos con 'Todos'

  @override
  void initState() {
    super.initState();
    currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    db = Database();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 50),
          _buildFilterButtons(), // Sección de botones para filtrar
          Expanded(
            child: StreamBuilder<List<Pet>>(
              stream: selectedInterest == 'Todos'
                  ? db.getUserPetsStream(currentUid) // Todos los intereses
                  : db.getFilteredUserPetsStream(currentUid, selectedInterest), // Filtrado por interés
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error al cargar mascotas."));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No tienes mascotas registradas."));
                }

                final pets = snapshot.data!;
                return GridView.builder(
                  itemCount: pets.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    return PetWidget(
                      pet: pets[index],
                      index: index,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPetScreen()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Color.fromARGB(255, 222, 49, 99),
      ),
    );
  }

  // Función para construir los botones de filtro
  Widget _buildFilterButtons() {
  final interests = [
    {'label': 'Todos', 'image': 'assets/livestock.png'},
    {'label': 'Perros', 'image': 'assets/dog.png'},
    {'label': 'Gatos', 'image': 'assets/cat.png'},
    {'label': 'Aves', 'image': 'assets/chick.png'},
    {'label': 'Roedores', 'image': 'assets/rabbit.png'},
    {'label': 'Otros', 'image': 'assets/monkey.png'},
  ];

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: interests.map((interest) {
        final isSelected = selectedInterest == interest['label'];
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedInterest = interest['label']!;
            });
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            //elevation: isSelected ? 6 : 2, // Más elevación si está seleccionado
            color: isSelected ? Color.fromARGB(255, 237, 84, 127) : Colors.white,
            child: Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    interest['image']!, // Imagen de los intereses
                    height: 50,
                    width: 50,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    interest['label']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Color.fromARGB(255, 255, 255, 255) : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}

}
