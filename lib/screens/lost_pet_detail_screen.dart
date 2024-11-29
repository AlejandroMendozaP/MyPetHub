import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mypethub/firebase/database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

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

  Future<void> _sendNotification(String userId) async {
    try {
      // Eliminar "/users/" para obtener el userId
      final userDocId = userId.replaceFirst('/users/', '');

      // Obtener el token FCM del usuario desde Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userDocId)
          .get();

      final fcmToken = userDoc.data()?['fcmToken'];

      if (fcmToken == null) {
        print("Token FCM no encontrado para el usuario.");
        return;
      }

      // Construir el cuerpo de la notificación
      final message = {
        "to": fcmToken,
        "notification": {
          "title": "Nueva información sobre tu mascota perdida",
          "body": "Alguien tiene información sobre tu publicación. Revisa la app.",
        },
        "data": {
          "screen": "LostPetDetailScreen",
          "lostPetId": lostPetId,
        },
      };

      // Enviar la notificación a través de FCM
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=AIzaSyC6XUX6vrj3UlPo0go_XxkndW2PYFpAn1Q', // Reemplaza con tu clave de servidor FCM
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print("Notificación enviada con éxito.");
      } else {
        print("Error al enviar la notificación: ${response.body}");
      }
    } catch (e) {
      print("Error al enviar la notificación: $e");
    }
  }

  void _onInfoButtonPressed(BuildContext context, String userId) {
    _sendNotification(userId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Información enviada"),
        content: Text("El propietario ha sido notificado. Gracias por tu ayuda."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cerrar"),
          ),
        ],
      ),
    );
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
        final userId = lostPetData['userId'];

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
              /*SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _onInfoButtonPressed(context, userId),
                child: Text("Tengo información"),
              ),*/
            ],
          ),
        );
      },
    );
  }
}
