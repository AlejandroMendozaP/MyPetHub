import 'package:flutter/material.dart';
import 'package:mypethub/models/pet.dart';
import 'package:mypethub/screens/pet_detail_screen.dart';

class PetWidget extends StatelessWidget {
  final Pet pet;
  final int index;

  PetWidget({required this.pet, required this.index});

  String getAge(DateTime birthdate) {
    final now = DateTime.now();
    final age = now.difference(birthdate).inDays ~/ 365;
    return '$age años';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PetDetailScreen(petId: pet.id)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 3,
              offset: Offset(0, 5),
            ),
          ],
        ),
        margin: EdgeInsets.symmetric(horizontal: index == 0 ? 16 : 8, vertical: 10),
        width: 240,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: pet.photo,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(pet.photo),
                          fit: BoxFit.contain,
                        ),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Información
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  Text(
                    pet.name,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  // Raza y sexo
                  Row(
                    children: [
                      Text(
                        '${pet.race} · ${pet.sex}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  // Edad
                  Row(
                    children: [
                      Icon(Icons.cake, color: Colors.grey[600], size: 16),
                      SizedBox(width: 4),
                      Text(
                        getAge(pet.birthdate),
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 8)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
