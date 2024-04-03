// ignore_for_file: use_build_context_synchronously, avoid_print, library_private_types_in_public_api

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:okeys/classes/annonce_class.dart';
import 'package:path/path.dart' as path;
import 'package:okeys/services/firebase_services.dart';
import 'package:http/http.dart' as http;

class UploadPage extends StatefulWidget {
  final Annonce? annonceToEdit;

  const UploadPage({super.key, this.annonceToEdit});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _m2Controller = TextEditingController();
  bool _jardin = false;
  bool _garage = false;
  bool _fibreOptique = false;
  File? _image;
  final picker = ImagePicker();
  String? selectedDepartementCode;
  final TextEditingController _departementController = TextEditingController();
  final TextEditingController _villeController = TextEditingController();
  UniqueKey _villeFieldKey = UniqueKey();
  String? selectedVilleCode;

  @override
  void initState() {
    super.initState();
    if (widget.annonceToEdit != null) {
      final annonce = widget.annonceToEdit!;
      _titreController.text = annonce.titre;
      _descriptionController.text = annonce.description;
      _prixController.text = annonce.prix.toString();
      _m2Controller.text = annonce.m2.toString();
      _jardin = annonce.jardin;
      _garage = annonce.garage;
      _fibreOptique = annonce.fibreOptique;
    }
  }

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadFile() async {
    String imageUrl;
    if (_image != null) {
      final fileName = path.basename(_image!.path);
      final destination = 'images/$fileName';
      final ref = FirebaseStorage.instance.ref(destination);
      await ref.putFile(_image!);
      imageUrl = await ref.getDownloadURL();
    } else {
      imageUrl = widget.annonceToEdit?.imageUrl ?? "";
    }

    final annonce = Annonce(
      id: widget.annonceToEdit?.id ?? '',
      titre: _titreController.text,
      description: _descriptionController.text,
      imageUrl: imageUrl,
      prix: double.parse(_prixController.text),
      m2: double.parse(_m2Controller.text),
      jardin: _jardin,
      garage: _garage,
      fibreOptique: _fibreOptique,
      departement: _departementController.text,
      ville: _villeController.text,
      codeDepartement: selectedDepartementCode ?? "",
      codeVille: selectedVilleCode ?? "",
    );

    if (widget.annonceToEdit == null) {
      // Ajout d'une nouvelle annonce
      await FirebaseServices().addAnnonce(annonce);
    } else {
      // Mise à jour de l'annonce existante
      await FirebaseServices().updateAnnonce(annonce);
    }

    Navigator.of(context).pop();
  }

  Future<List<Map<String, String>>> searchDepartements(String query) async {
    final url =
        Uri.parse('https://geo.api.gouv.fr/departements?nom=$query&limit=5');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> departements = json.decode(response.body);
      return departements
          .map((dep) => {
                "nom": dep['nom']
                    as String, // Assure-toi que 'nom' est bien une String
                "code": dep['code']
                    as String // Assure-toi que 'code' est bien une String
              })
          .toList();
    } else {
      throw Exception('Failed to load departements');
    }
  }

  Future<List<Map<String, String>>> searchVilles(
      String departementCode, String query) async {
    final url = Uri.parse(
        'https://geo.api.gouv.fr/communes?codeDepartement=$departementCode&nom=$query&limit=5');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List villes = json.decode(response.body);
      return villes
          .map((ville) => {
                "nom": ville['nom'] as String,
                "code": ville['code']
                    as String, // Suppose que l'API renvoie un champ 'code'
              })
          .toList();
    } else {
      throw Exception('Failed to load villes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mettre en ligne une annonce'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_image != null)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.black),
                      image: DecorationImage(
                        image: FileImage(_image!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Choisir une image'),
                ),
                TextFormField(
                  controller: _titreController,
                  decoration: const InputDecoration(labelText: 'Titre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un titre';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _prixController,
                  decoration: const InputDecoration(labelText: 'Prix'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un prix';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _m2Controller,
                  decoration: const InputDecoration(labelText: 'Surface en m²'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une surface';
                    }
                    return null;
                  },
                ),
                Autocomplete<Map<String, String>>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text == '') {
                      return const Iterable<Map<String, String>>.empty();
                    }
                    return await searchDepartements(textEditingValue.text);
                  },
                  displayStringForOption: (Map<String, String> option) =>
                      option['nom']!,
                  onSelected: (Map<String, String> selection) {
                    _departementController.text = selection['nom']!;
                    selectedDepartementCode = selection['code'];
                    // Réinitialiser la ville et regénérer la key pour forcer la reconstruction
                    _villeController.clear();
                    setState(() {
                      _villeFieldKey = UniqueKey();
                    });
                  },
                ),
                Autocomplete<Map<String, String>>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text == '' ||
                        selectedDepartementCode == null) {
                      return const Iterable<Map<String, String>>.empty();
                    }
                    return await searchVilles(
                        selectedDepartementCode!, textEditingValue.text);
                  },
                  displayStringForOption: (Map<String, String> option) =>
                      option['nom']!,
                  onSelected: (Map<String, String> selection) {
                    setState(() {
                      _villeController.text = selection['nom']!;
                      selectedVilleCode = selection[
                          'code']; // Stocker le code de la ville sélectionnée
                    });
                  },
                  fieldViewBuilder:
                      (_, controller, focusNode, onEditingComplete) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      onEditingComplete: onEditingComplete,
                      decoration: const InputDecoration(labelText: 'Ville'),
                      enabled: selectedDepartementCode != null,
                    );
                  },
                ),
                SwitchListTile(
                  title: const Text('Jardin'),
                  value: _jardin,
                  onChanged: (bool value) {
                    setState(() {
                      _jardin = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Garage'),
                  value: _garage,
                  onChanged: (bool value) {
                    setState(() {
                      _garage = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Fibre Optique'),
                  value: _fibreOptique,
                  onChanged: (bool value) {
                    setState(() {
                      _fibreOptique = value;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      uploadFile();
                    }
                  },
                  child: const Text('Publier l\'annonce'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}