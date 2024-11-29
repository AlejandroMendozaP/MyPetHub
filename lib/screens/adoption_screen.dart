import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mypethub/firebase/database.dart';
import 'package:mypethub/screens/adoption_pet_detail_screen.dart';

class AdoptionScreen extends StatelessWidget {
  const AdoptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: Database().getAdoptionPets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No hay mascotas en adopción en este momento.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final adoptionPets = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: adoptionPets.length,
            itemBuilder: (context, index) {
              final petData = adoptionPets[index]['pet'];
              final adoptionPetId = adoptionPets[index]['adoptionPet']['id']; // ID de adopción
              return _buildPetCard(context, petData, adoptionPetId);
            },
          );
        },
      ),
    );
  }

  Widget _buildPetCard(BuildContext context, Map<String, dynamic> petData, String adoptionPetId) {
    final String name = petData['name'] ?? 'Sin nombre';
    final String sex = petData['sex'] ?? 'Desconocido';
    final String photoUrl = petData['photo'] ??
        'https://via.placeholder.com/150'; // Imagen por defecto
    final DateTime? birthdate = petData['birthdate'] != null
        ? (petData['birthdate'] as Timestamp).toDate()
        : null;

    // Calcular edad
    final String age = birthdate != null
        ? '${DateTime.now().year - birthdate.year} años'
        : 'Edad desconocida';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdoptionPetDetailScreen(adoptionPetId: adoptionPetId),
          ),
        );
      },
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Imagen de la mascota
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  photoUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.pets, size: 80, color: Colors.grey);
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Información de la mascota
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // Sexo con ícono
                    Row(
                      children: [
                        Icon(
                          sex.toLowerCase() == 'macho'
                              ? Icons.male
                              : Icons.female,
                          color: Colors.blueGrey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          sex,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Edad con ícono
                    Row(
                      children: [
                        const Icon(
                          Icons.cake,
                          color: Colors.blueGrey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          age,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
