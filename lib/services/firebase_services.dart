// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:okeys/classes/annonce_class.dart';
import 'package:okeys/classes/user_class.dart';
import 'package:okeys/classes/visite_class.dart';

class FirebaseServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ! GESTION DES UTILISATEURS
  // Inscription d'un nouvel utilisateur
  Future<AppUser?> signUp({
    required String email,
    required String password,
    required String nom,
    required String prenom,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        AppUser user = AppUser(
          id: firebaseUser.uid,
          email: email,
          nom: nom,
          prenom: prenom,
        );

        // Sauvegarder l'utilisateur dans Firestore
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(user.toJson());

        return user;
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Connexion d'un utilisateur
  Future<AppUser?> signIn(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Récupération des informations supplémentaires de l'utilisateur depuis Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (userDoc.exists) {
          AppUser user = AppUser.fromJson(
              userDoc.data() as Map<String, dynamic>, firebaseUser.uid);
          return user;
        }
      }
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Méthode pour récupérer l'utilisateur actuel et son rôle
  Future<AppUser?> getCurrentUser() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (userDoc.exists) {
        return AppUser.fromJson(
          userDoc.data() as Map<String, dynamic>,
          firebaseUser.uid,
        );
      }
    }
    return null;
  }

  // ! GESTION DES ANNONCES
  // Ajouter une nouvelle annonce
  Future<void> addAnnonce(Annonce annonce) async {
    await _firestore.collection('annonces').add(annonce.toJson());
  }

  // Lire les annonces
  Future<List<Annonce>> fetchAnnonces() async {
    QuerySnapshot snapshot = await _firestore.collection('annonces').get();
    return snapshot.docs
        .map((doc) =>
            Annonce.fromJson(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Mettre à jour une annonce
  Future<void> updateAnnonce(Annonce annonce) async {
    await _firestore
        .collection('annonces')
        .doc(annonce.id)
        .update(annonce.toJson());
  }

  // Supprimer une annonce
  Future<void> deleteAnnonce(String id) async {
    await _firestore.collection('annonces').doc(id).delete();
  }

  // ! GESTION DES VISITES
  // Ajouter une nouvelle visite
  Future<void> addVisite(Visite visite) async {
    await _firestore.collection('visites').add(visite.toJson());
  }

  // Mettre à jour une visite
  Future<void> updateVisite(Visite visite) async {
    await _firestore
        .collection('visites')
        .doc(visite.id)
        .update(visite.toJson());
  }

  // Supprimer une visite
  Future<void> deleteVisite(String id) async {
    await _firestore.collection('visites').doc(id).delete();
  }

  Future<AppUser?> getUserById(String id) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(id).get();
    return doc.exists ? AppUser.fromJson(doc.data()!, doc.id) : null;
  }

  Stream<List<AppUser>> getAllAgents() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppUser.fromJson(doc.data(), doc.id))
            .toList());
  }
}