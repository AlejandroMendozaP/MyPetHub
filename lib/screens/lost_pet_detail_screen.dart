import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mypethub/firebase/database.dart';
import 'package:mypethub/models/pet.dart';

class LostPetDetailScreen extends StatelessWidget {
  final String lostPetId; // ID de la mascota perdida

  LostPetDetailScreen({required this.lostPetId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: Database().getLostPetDetails(lostPetId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            body: Center(
                child: Text("No se encontraron datos de la mascota perdida.")),
          );
        }

        final lostPetData = snapshot.data!;
        final petData = lostPetData['petDetails'] ?? {};
        final petPhoto = petData['photo'] ?? lostPetData['photo'] ?? '';
        final petName = petData['name'] ?? 'Desconocido';
        final petDescription = petData['description'] ??
            lostPetData['description'] ??
            'Sin descripción';
        final losDescription = lostPetData['description'] ?? 'Sin descripción';
        final petRace = petData['race'] ?? 'Desconocida';
        final ownerEmail =
            lostPetData['contactInfo']['email'] ?? 'No disponible';
        final ownerPhone =
            lostPetData['contactInfo']['phone'] ?? 'No disponible';
        final lastSeenLocation = LatLng(
          lostPetData['lastSeenLocation']['latitude'],
          lostPetData['lastSeenLocation']['longitude'],
        );
        final lastSeenDate = lostPetData['lastSeenDate'] ?? 'Fecha desconocida';

        return Scaffold(
          appBar: AppBar(
            title: Text("Detalle de Mascota Perdida"),
          ),
          body: ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              Container(
                height: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(petPhoto),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              SizedBox(height: 16),
              Text(
                petName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text("Raza: $petRace", style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text(petDescription, style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              Text(
                "Información de contacto",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text("Email: $ownerEmail"),
              Text("Teléfono: $ownerPhone"),
              SizedBox(height: 16),
              Text(
                "Última ubicación vista",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Container(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: lastSeenLocation,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId("lastSeen"),
                      position: lastSeenLocation,
                      infoWindow: InfoWindow(
                        title: "Última ubicación",
                        snippet: "Visto el $lastSeenDate",
                      ),
                    ),
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
