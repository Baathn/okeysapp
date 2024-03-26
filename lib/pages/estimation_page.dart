// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Estimation Immobilière',
      home: EstimationPage(),
    );
  }
}

class EstimationPage extends StatefulWidget {
  const EstimationPage({super.key});

  @override
  _EstimationPageState createState() => _EstimationPageState();
}

class _EstimationPageState extends State<EstimationPage> {
  List<dynamic> _departments = [];
  List<dynamic> _communes = [];
  String? _selectedDept;
  String _communeName = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    final response = await http
        .get(Uri.parse('https://geo.api.gouv.fr/departements?fields=nom,code'));
    if (response.statusCode == 200) {
      setState(() {
        _departments = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load departments');
    }
  }

  Future<void> _fetchCommunes(String deptCode) async {
    final response = await http.get(
      Uri.parse(
          'https://geo.api.gouv.fr/departements/$deptCode/communes?fields=nom,code,population'),
    );
    if (response.statusCode == 200) {
      setState(() {
        _communes = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load communes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estimation Immobilière'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                DropdownButtonFormField<String>(
                  hint: const Text('Choisir un département'),
                  value: _selectedDept,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedDept = newValue;
                      _fetchCommunes(newValue!);
                    });
                  },
                  items: _departments.map((dept) {
                    return DropdownMenuItem<String>(
                      value: dept['code'],
                      child: Text(dept['nom']),
                    );
                  }).toList(),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Commune'),
                  onChanged: (value) {
                    setState(() {
                      _communeName = value;
                      // Filtrer les communes pour trouver celle qui correspond au nom saisi
                      var selectedCommune = _communes.firstWhere(
                        (commune) => commune['nom']
                            .toLowerCase()
                            .contains(_communeName.toLowerCase()),
                        orElse: () => null,
                      );
                      if (selectedCommune != null) {}
                    });
                  },
                ),
                // Ajoutez ici d'autres champs pour le nombre de pièces, m2, garage, jardin, fibre optique...
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Calculer l'estimation ici
                      int estimation = _calculateEstimation(
                          // nombrePieces, surface, jardin, garage, fibre, _population
                          );
                      // Afficher le résultat de l'estimation
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text('Estimation : $estimation €'),
                          );
                        },
                      );
                    }
                  },
                  child: const Text('Estimer le bien'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _calculateEstimation(
      /* int nombrePieces, int surface, bool jardin, bool garage, bool fibre, int population */) {
    // Mettre en place la logique de calcul d'estimation ici...
    return 0; // Retournez le calcul d'estimation
  }
}
