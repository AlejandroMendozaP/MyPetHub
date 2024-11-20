import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  final String id;
  final String name;
  final String race;
  final String sex;
  final String color;
  final DateTime birthdate;
  final String userid;
  final String description;
  final String photo;

  Pet({
    required this.id,
    required this.name,
    required this.race,
    required this.sex,
    required this.color,
    required this.birthdate,
    required this.userid,
    required this.description,
    required this.photo
  });

  // Método para convertir un documento Firestore a un objeto Pet
  factory Pet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Pet(
      id: doc.id, // Extrae el ID del documento
      name: data['name'] ?? '',
      race: data['race'] ?? '',
      sex: data['sex'] ?? '',
      color: data['color'] ?? '',
      description: data['description'] ?? '',
      birthdate: (data['birthdate'] as Timestamp).toDate(),
      photo: data['photo'] ?? '',
      userid: data['userid'] ?? '',
    );
  }

  // Método para convertir un objeto Pet a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'race': race,
      'sex': sex,
      'color': color,
      'description': description,
      'birthdate': birthdate,
      'photo': photo,
    };
  }
}
