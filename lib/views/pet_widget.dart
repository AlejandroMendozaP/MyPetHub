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
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PetDetailScreen(petId: pet.id)),
        );
      },
      child: Container(
        margin:
            EdgeInsets.symmetric(horizontal: index == 0 ? 16 : 8, vertical: 10),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: theme.brightness == Brightness.dark
              ? Border.all(color: Colors.white.withOpacity(0.2))
              : null,
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.light
                  ? Colors.grey.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
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
                          fit: BoxFit.cover,
                        ),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
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
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  // Raza y sexo
                  Row(
                    children: [
                      Text(
                        '${pet.race} · ${pet.sex}',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.hintColor),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  // Edad
                  Row(
                    children: [
                      Icon(Icons.cake, color: theme.hintColor, size: 16),
                      SizedBox(width: 4),
                      Text(
                        getAge(pet.birthdate),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.hintColor),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
