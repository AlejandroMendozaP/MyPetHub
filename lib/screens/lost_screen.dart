import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mypethub/firebase/database.dart';
import 'lost_pet_detail_screen.dart'; // Importa la pantalla de detalle

class LostScreen extends StatelessWidget {
  final Database database = Database();

  LostScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  height: 150,
                  child: Lottie.asset('assets/lostpet.json'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: database.getLostPetsWithDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay mascotas perdidas.'));
                }

                final lostPetsWithDetails = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: lostPetsWithDetails.length,
                  itemBuilder: (context, index) {
                    final lostPetData = lostPetsWithDetails[index]['lostPet'];
                    final petData = lostPetsWithDetails[index]['pet'];

                    final name = petData['name'] ?? 'Sin nombre';
                    final photoUrl = petData['photo'] ??
                        'https://via.placeholder.com/150'; // Imagen por defecto
                    final lastSeenDate =
                        lostPetData['lastSeenDate'] ?? 'Desconocido';
                    final lostPetId = lostPetData['id'] ?? 'Desconocido'; // Extrae el ID de `lostPet`

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LostPetDetailScreen(lostPetId: lostPetId),
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
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(photoUrl),
                                radius: 40,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Visto por última vez: $lastSeenDate',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
