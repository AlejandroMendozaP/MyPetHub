import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:mypethub/models/pet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Stream<List<Pet>> getUserPetsStream(String uid) {
  try {
    // Realiza la consulta a la colección "pets"
    return firebaseFirestore
        .collection('pets')
        .where('userid', isEqualTo: '/users/$uid') // Filtra por UID
        .snapshots()
        .map((snapshot) {
      // Mapea los documentos a objetos `Pet`
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
    });
  } catch (e) {
    print("Error al obtener las mascotas en tiempo real: $e");
    // Devuelve un stream vacío en caso de error
    return Stream.value([]);
  }
}


  Future<bool> reportLostPet(Map<String, dynamic> lostPetData) async {
    try {
      await firebaseFirestore.collection('lostpets').add(lostPetData);
      return true;
    } catch (e) {
      print("Error al reportar mascota perdida: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getLostPetsWithDetails() async {
    try {
      // Obtener todos los documentos de la colección "lostpets"
      QuerySnapshot lostPetsSnapshot =
          await firebaseFirestore.collection('lostpets').get();

      // Iterar sobre los documentos para obtener la información completa
      List<Map<String, dynamic>> lostPetsWithDetails = [];

      for (var doc in lostPetsSnapshot.docs) {
        final lostPetData = doc.data() as Map<String, dynamic>;

        // Obtener el ID de la mascota
        final petId = lostPetData['petId'] ?? '';

        if (petId.isNotEmpty) {
          // Consultar la información de la mascota en la colección "pets"
          DocumentSnapshot petDoc =
              await firebaseFirestore.collection('pets').doc(petId).get();

          if (petDoc.exists) {
            final petData = petDoc.data() as Map<String, dynamic>;

            // Combinar los datos de "lostpets" con los de "pets"
            lostPetsWithDetails.add({
              'lostPet': {
                ...lostPetData,
                'id': doc.id, // Incluye el ID del documento
              },
              'pet': petData,
            });
          }
        }
      }

      return lostPetsWithDetails;
    } catch (e) {
      print("Error al obtener mascotas perdidas con detalles: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getLostPetDetails(String petId) async {
    try {
      // Obtener los datos de la mascota perdida
      DocumentSnapshot lostPetSnapshot =
          await firebaseFirestore.collection('lostpets').doc(petId).get();

      if (!lostPetSnapshot.exists) return null;

      final lostPetData = lostPetSnapshot.data() as Map<String, dynamic>;

      // Obtener los datos de la mascota asociada
      final associatedPetId = lostPetData['petId'] ?? '';
      Map<String, dynamic>? petData;

      if (associatedPetId.isNotEmpty) {
        DocumentSnapshot petSnapshot = await firebaseFirestore
            .collection('pets')
            .doc(associatedPetId)
            .get();

        if (petSnapshot.exists) {
          petData = petSnapshot.data() as Map<String, dynamic>;
        }
      }

      // Obtener los datos del usuario
      final userId = lostPetData['userId']?.split('/').last ??
          ''; // Extraer el ID del usuario
      Map<String, dynamic>? userData;

      if (userId.isNotEmpty) {
        DocumentSnapshot userSnapshot =
            await firebaseFirestore.collection('users').doc(userId).get();

        if (userSnapshot.exists) {
          userData = userSnapshot.data() as Map<String, dynamic>;
        }
      }

      // Combinar todos los datos
      return {
        ...lostPetData,
        if (petData != null) 'petDetails': petData,
        if (userData != null) 'userDetails': userData,
      };
    } catch (e) {
      print("Error al obtener detalles de la mascota perdida: $e");
      return null;
    }
  }

  Future<void> deletePet(String petId) async {
    try {
      // Inicia una transacción para asegurar consistencia
      await firebaseFirestore.runTransaction((transaction) async {
        // Eliminar de la colección `pets`
        transaction.delete(firebaseFirestore.collection('pets').doc(petId));

        // Eliminar de la colección `lostpets`
        final lostPetsSnapshot = await firebaseFirestore
            .collection('lostpets')
            .where('petId', isEqualTo: petId)
            .get();

        for (final doc in lostPetsSnapshot.docs) {
          transaction.delete(doc.reference);
        }
      });
    } catch (e) {
      print("Error al eliminar la mascota: $e");
      throw Exception("No se pudo eliminar la mascota.");
    }
  }

}
