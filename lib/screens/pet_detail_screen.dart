import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mypethub/firebase/database.dart';
import 'package:mypethub/models/pet.dart';
import 'package:mypethub/screens/add_pet_screen.dart';
import 'package:mypethub/screens/adoption_report_screen.dart';
import 'package:mypethub/screens/report_lost_pet_screen.dart';

class PetDetailScreen extends StatelessWidget {
  final String petId;

  PetDetailScreen({required this.petId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('pets').doc(petId).snapshots(),
      builder: (context, petSnapshot) {
        if (petSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!petSnapshot.hasData || !petSnapshot.data!.exists) {
          return Scaffold(
            body: Center(child: Text("No se encontró la mascota")),
          );
        }

        final petData = petSnapshot.data!.data() as Map<String, dynamic>;
        final pet = Pet.fromFirestore(petSnapshot.data!);

        // Verificar si la mascota está "perdida"
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('lostpets')
              .where('petId', isEqualTo: petId)
              .snapshots(),
          builder: (context, lostPetSnapshot) {
            if (lostPetSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final isLost = lostPetSnapshot.hasData &&
                lostPetSnapshot.data!.docs.isNotEmpty;

            // Verificar si la mascota está en adopción solo si no está perdida
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('adoptionpets')
                  .where('petId', isEqualTo: petId)
                  .snapshots(),
              builder: (context, adoptionPetSnapshot) {
                if (adoptionPetSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final isInAdoption = adoptionPetSnapshot.hasData &&
                    adoptionPetSnapshot.data!.docs.isNotEmpty;

                // Decidir qué botones mostrar según el estado
                List<Widget> actionButtons;

                if (isLost) {
                  actionButtons = [
                    _buildOptionButton(
                      "¡Encontré a mi mascota!",
                      Icons.check_circle_outline,
                      () {
                        _markPetAsFound(petId);
                      },
                      Colors.green[300],
                    ),
                  ];
                } else if (isInAdoption) {
                  actionButtons = [
                    _buildOptionButton(
                      "Ya no quiero dar en adopción",
                      Icons.undo,
                      () {
                        _removeFromAdoption(petId);
                      },
                      Colors.orange,
                    ),
                    _buildOptionButton(
                      "Ya ha sido adoptado",
                      Icons.check_circle,
                      () {
                        _markAsAdopted(petId);
                      },
                      Colors.green,
                    ),
                  ];
                } else {
                  actionButtons = [
                    _buildOptionButton(
                      "Editar datos",
                      Icons.edit,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddPetScreen(pet: pet),
                          ),
                        );
                      },
                      Colors.grey[200],
                    ),
                    _buildOptionButton(
                      "¡Mi mascota se ha perdido!",
                      Icons.warning_rounded,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportLostPetScreen(
                              userId: pet.userid,
                              petId: pet.id,
                            ),
                          ),
                        );
                      },
                      const Color.fromARGB(255, 227, 106, 106),
                    ),
                    _buildOptionButton(
                      "Dar en adopción",
                      Icons.house_siding_rounded,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdoptionReportScreen(
                              userId: pet.userid,
                              petId: pet.id,
                            ),
                          ),
                        );
                      },
                      const Color.fromARGB(255, 240, 175, 72),
                    ),
                    // Botón de eliminación
                    _buildOptionButton(
                      "Eliminar Mascota",
                      Icons.delete_outline,
                      () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Eliminar Mascota"),
                            content: Text(
                                "¿Estás seguro de que deseas eliminar esta mascota? Esta acción no se puede deshacer."),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text("Cancelar"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text("Eliminar"),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            await Database().deletePet(petId);
                            Navigator.pop(
                                context); // Volver a la pantalla anterior tras eliminar
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text("Error al eliminar la mascota: $e")),
                            );
                          }
                        }
                      },
                      Colors.red[300],
                    ),
                  ];
                }

                return Scaffold(
                  extendBodyBehindAppBar: true,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back),
                    ),
                  ),
                  body: ListView(
                    children: [
                      // Imagen de la mascota
                      Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(pet.photo),
                            fit: BoxFit.contain,
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      // Detalles de la mascota
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pet.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  "Raza: ${pet.race}",
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 14),
                                ),
                                SizedBox(width: 16),
                                Text(
                                  "Sexo: ${pet.sex}",
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 14),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                buildPetFeature(pet.color, "Color"),
                                buildPetFeature(
                                  "${pet.birthdate.day}/${pet.birthdate.month}/${pet.birthdate.year}",
                                  "Fecha de nacimiento",
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Unos datos extras sobre ${pet.name}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            SizedBox(height: 8),
                            Text(
                              pet.description.isNotEmpty
                                  ? pet.description
                                  : "No se ha proporcionado una descripción.",
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 16),
                            ),
                            SizedBox(height: 32),

                            // Botones dinámicos
                            ...actionButtons,
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOptionButton(
      String title, IconData leadingIcon, VoidCallback onTap, Color? color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(leadingIcon, color: Colors.black54),
                SizedBox(width: 15),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget buildPetFeature(String value, String feature) {
    return Expanded(
      child: Container(
        height: 70,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              feature,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _markPetAsFound(String petId) async {
    try {
      final lostPetsRef = FirebaseFirestore.instance.collection('lostpets');
      final query = await lostPetsRef.where('petId', isEqualTo: petId).get();

      for (var doc in query.docs) {
        await doc.reference.delete(); // Eliminar el registro
      }
    } catch (e) {
      print("Error al marcar como encontrada: $e");
    }
  }

  Future<void> _removeFromAdoption(String petId) async {
    try {
      final adoptionPetsRef =
          FirebaseFirestore.instance.collection('adoptionpets');
      final query =
          await adoptionPetsRef.where('petId', isEqualTo: petId).get();

      for (var doc in query.docs) {
        await doc.reference.delete(); // Eliminar el registro de adopción
      }
    } catch (e) {
      print("Error al eliminar de adopción: $e");
    }
  }

  Future<void> _markAsAdopted(String petId) async {
    try {
      final adoptionPetsRef =
          FirebaseFirestore.instance.collection('adoptionpets');
      final query =
          await adoptionPetsRef.where('petId', isEqualTo: petId).get();

      for (var doc in query.docs) {
        await doc.reference.delete(); // Eliminar de adopción
      }
      // Aquí podrías agregar lógica adicional, como mover la mascota a una colección de "adoptadas"
    } catch (e) {
      print("Error al marcar como adoptada: $e");
    }
  }
}
