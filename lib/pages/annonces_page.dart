// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:okeys/pages/info_page.dart';
import 'package:okeys/pages/upload_page.dart';
import 'package:okeys/services/firebase_services.dart';
import 'package:okeys/classes/annonce_class.dart';

class AnnoncePage extends StatefulWidget {
  const AnnoncePage({super.key});

  @override
  _AnnoncePageState createState() => _AnnoncePageState();
}

class _AnnoncePageState extends State<AnnoncePage> {
  bool isLoading = true;
  List<Annonce> annonces = [];

  @override
  void initState() {
    super.initState();
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
        title: const Text('Annonces'),
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
                        ButtonBar(
                          alignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (context) =>
                                            UploadPage(annonceToEdit: annonce)))
                                    .then((_) => fetchAnnonces());
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Supprimer l\'annonce'),
                                      content: const Text(
                                          'Êtes-vous sûr de vouloir supprimer cette annonce ?'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Annuler'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                        TextButton(
                                          child: const Text('Supprimer'),
                                          onPressed: () {
                                            FirebaseServices()
                                                .deleteAnnonce(annonce.id);
                                            setState(
                                                () => annonces.removeAt(index));
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
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
