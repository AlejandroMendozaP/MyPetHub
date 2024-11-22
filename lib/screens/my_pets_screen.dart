// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mypethub/firebase/database.dart';
import 'package:mypethub/models/pet.dart';
import 'package:mypethub/screens/add_pet_screen.dart';
import 'package:mypethub/views/pet_widget.dart';

class MyPetsScreen extends StatefulWidget {
  @override
  _MyPetsScreenState createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  late Future<List<Pet>> _petsFuture;

  @override
  void initState() {
    super.initState();
    String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    Database db = Database();
    _petsFuture = db.getUserPets(currentUid);
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: FutureBuilder<List<Pet>>(
      future: _petsFuture,
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
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddPetScreen()),
        ).then((_) {
          // Refresca la lista después de registrar una nueva mascota
          setState(() {
            String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
            _petsFuture = Database().getUserPets(currentUid);
          });
        });
      },
      child: Icon(Icons.add, color: Colors.white,),
      backgroundColor: Color.fromARGB(
                      255, 222, 49, 99),
    ),
  );
}
}