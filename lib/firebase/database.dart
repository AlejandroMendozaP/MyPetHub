import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
      final querySnapshot = await firebaseFirestore.collection('intereses').get();
      return querySnapshot.docs.map((doc) => doc['interes'] as String).toList();
    } catch (e) {
      print("Error al obtener intereses: $e");
      return [];
    }
  }
}
