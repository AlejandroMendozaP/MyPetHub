import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mypethub/firebase/database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class AdoptionPetDetailScreen extends StatelessWidget {
  final String adoptionPetId;

  AdoptionPetDetailScreen({required this.adoptionPetId});

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': "Información sobre la adopción de tu mascota"},
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
      future: Database().getAdoptionPetDetails(adoptionPetId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            body: Center(child: Text("No se encontraron datos de la mascota para adopción.")),
          );
        }

        final adoptionPetData = snapshot.data!;
        final petData = adoptionPetData['petDetails'] ?? {};
        final userData = adoptionPetData['userDetails'] ?? {};
        final petPhoto = petData['photo'] ?? adoptionPetData['photo'] ?? '';
        final petName = petData['name'] ?? 'Nombre no disponible';
        final petDescription = petData['description'] ?? 'Sin descripción';
        final adoptionDescription = adoptionPetData['description'] ?? 'Sin descripción';
        final userPhoto = userData['photo'] ?? '';
        final userName = userData['name'] ?? 'Usuario desconocido';
        final userEmail =
            adoptionPetData['contactInfo']['email'] ?? 'Correo no disponible';
        final userPhone =
            adoptionPetData['contactInfo']['phone'] ?? 'Teléfono no disponible';

        return Scaffold(
          appBar: AppBar(
            title: Text("Detalles de Adopción"),
          ),
          body: ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              // Imagen de la mascota
              Container(
                height: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(petPhoto),
                    fit: BoxFit.contain,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              SizedBox(height: 16),

              // Nombre de la mascota
              Row(
                children: [
                  Icon(Icons.pets),
                  SizedBox(width: 8),
                  Text(
                    petName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Subtítulo y descripción de la mascota
              Text(
                "Descripción de la mascota",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              Text(
                petDescription,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              // Subtítulo y motivo de adopción
              Text(
                "¿Por qué se está dando en adopción?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              Text(
                adoptionDescription,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              // Subtítulo y datos del dueño actual
              Text(
                "Actual dueño",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(userPhoto),
                    radius: 30,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 4),
                        Text(
                          userEmail,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
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
            ],
          ),
        );
      },
    );
  }
}
