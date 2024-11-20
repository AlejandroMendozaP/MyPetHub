import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:mypethub/models/pet.dart';

class Database {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  CollectionReference? collectionReference;

  Database() {
    collectionReference = firebaseFirestore.collection('users');
  }

  Future<bool> insertUser(String uid, Map<String, dynamic> userInfo) async {
    try {
      await collectionReference!.doc(uid).set(userInfo);
      return true;
    } catch (e) {
      print("Error al insertar el usuario: $e");
      return false;
    }
  }

  Future<bool> delete(String UId) async {
    try {
      collectionReference!.doc(UId).delete();
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> update(Map<String, dynamic> movies, String UId) async {
    try {
      collectionReference!.doc(UId).update(movies);
      return true;
    } catch (e) {
      kDebugMode ? print(e) : '';
    }
    return false;
  }

  Stream<QuerySnapshot> select() {
    return collectionReference!.snapshots();
  }

  Future<List<String>> fetchInterests() async {
    try {
      final querySnapshot =
          await firebaseFirestore.collection('intereses').get();
      return querySnapshot.docs.map((doc) => doc['interes'] as String).toList();
    } catch (e) {
      print("Error al obtener intereses: $e");
      return [];
    }
  }

  Future<List<Pet>> getUserPets(String uid) async {
    try {
      // Realizar la consulta a la colección "pets"
      QuerySnapshot snapshot = await firebaseFirestore
          .collection('pets')
          .where('userid', isEqualTo: '/users/$uid') // Filtra por UID
          .get();

      // Mapear los documentos a objetos `Pet`
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Pet(
          id: doc.id, // Extrae el ID del documento
          name: data['name'] ?? '',
          race: data['race'] ?? '',
          sex: data['sex'] ?? '',
          color: data['color'] ?? '',
          birthdate: (data['birthdate'] as Timestamp).toDate(),
          userid: data['userid'] ?? '',
          description: data['description'] ?? '',
          photo: data['photo'] ?? '',
        );
      }).toList();
    } catch (e) {
      print("Error al obtener las mascotas: $e");
      return [];
    }
  }
}
