// ignore_for_file: unused_element, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:okeys/classes/user_class.dart';
import 'package:okeys/pages/annonces_page.dart';
import 'package:okeys/services/firebase_services.dart';
import 'package:okeys/pages/info_page.dart';
import 'package:okeys/pages/upload_page.dart';
import 'package:okeys/classes/annonce_class.dart';

class CenterPage extends StatefulWidget {
  const CenterPage({super.key});

  @override
  _CenterPageState createState() => _CenterPageState();
}

class _CenterPageState extends State<CenterPage> {
  AppUser? currentUser;
  bool isLoading = true;
  List<Annonce> annonces = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    FirebaseServices firebaseServices = FirebaseServices();
    AppUser? user = await firebaseServices.getCurrentUser();
    if (user != null) {
      setState(() {
        currentUser = user;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
    fetchAnnonces();
  }

  fetchAnnonces() async {
    annonces = await FirebaseServices().fetchAnnonces();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Okeys - Accueil'),
        centerTitle: true,
        actions: [
          if (currentUser?.role == 'admin') ...[
            IconButton(
              icon: const Icon(Icons.upload),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UploadPage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.photo_size_select_actual),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AnnoncePage(),
                  ),
                );
              },
            ),
          ],
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Deux éléments par ligne
                crossAxisSpacing: 10, // Espace horizontal entre les cartes
                mainAxisSpacing: 10, // Espace vertical entre les cartes
                childAspectRatio: 0.8,
              ),
              padding: const EdgeInsets.all(10),
              itemCount: annonces.length,
              itemBuilder: (context, index) {
                Annonce annonce = annonces[index];
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => InfoPage(annonce: annonce),
                      ),
                    );
                  },
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Image.network(annonce.imageUrl,
                              fit: BoxFit.cover),
                        ),
                        ListTile(
                          title: Text(
                            annonce.titre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text('${annonce.prix}€ - ${annonce.m2}m²'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
