import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mypethub/firebase/database.dart';
import 'package:mypethub/models/pet.dart';
import 'package:url_launcher/url_launcher.dart';

class LostPetDetailScreen extends StatelessWidget {
  final String lostPetId;

  LostPetDetailScreen({required this.lostPetId});

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': "Información sobre tu mascota perdida"},
    );
    await launchUrl(emailUri);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

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
        final userData = lostPetData['userDetails'] ?? {};
        final petPhoto = petData['photo'] ?? lostPetData['photo'] ?? '';
        final petName = petData['name'] ?? 'Desconocido';
        final userPhoto = userData['photo'] ?? '';
        final userName = userData['name'] ?? 'Usuario desconocido';
        final userEmail =
            lostPetData['contactInfo']['email'] ?? 'Correo no disponible';
        final userPhone =
            lostPetData['contactInfo']['phone'] ?? 'Teléfono no disponible';
        final petDescription = petData['description'] ?? 
            lostPetData['description'] ?? 'Sin descripción';
        final lostDescription = lostPetData['description'] ?? 'Sin descripción';
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
              Row(children: [
                Icon(Icons.pets),
                SizedBox(width: 8),
                Text(
                  petName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ]),
              SizedBox(height: 8),
              Text(petDescription, style: TextStyle(fontSize: 16)),
              SizedBox(height: 5),
              Text(lostDescription, style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(userPhoto),
                    radius: 30,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      userName,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.email),
                    onPressed: () {
                      _launchEmail(userEmail);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.phone),
                    onPressed: () {
                      _makePhoneCall(userPhone);
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(children: [
                Icon(Icons.location_on_rounded),
                SizedBox(width: 8),
                Text(
                  "Última ubicación vista",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ]),
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
