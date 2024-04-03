import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:okeys/classes/annonce_class.dart';
import 'package:okeys/classes/user_class.dart';
import 'package:okeys/classes/visite_class.dart';
import 'package:okeys/services/firebase_services.dart';

class InfoPage extends StatelessWidget {
  final Annonce annonce;

  const InfoPage({Key? key, required this.annonce}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(annonce.titre),
      ),
      body: InfoBody(annonce: annonce),
    );
  }
}

class InfoBody extends StatefulWidget {
  final Annonce annonce;

  const InfoBody({Key? key, required this.annonce}) : super(key: key);

  @override
  _InfoBodyState createState() => _InfoBodyState();
}

class _InfoBodyState extends State<InfoBody> {
  final TextEditingController _dateController = TextEditingController();
  late DateTime _selectedDate;
  AppUser? _selectedAgent;
  List<String> risks = [];
  bool isLoading = true;
  late String inseeCode = widget.annonce.codeVille;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    fetchRisksData();
  }

   Future<void> fetchRisksData() async {
    try {
      // Remplacez 'YOUR_INSEE_CODE' par votre variable contenant le code INSEE
      var response = await http.get(Uri.parse(
          'https://georisques.gouv.fr/api/v1/gaspar/risques?rayon=1000&code_insee=$inseeCode'));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('data') &&
            data['data'] is List &&
            data['data'].isNotEmpty &&
            data['data'][0].containsKey('risques_detail')) {
          List<dynamic> risksData = data['data'][0]['risques_detail'];
          List<String> riskNames = risksData.map((risk) {
  return utf8.decode(risk['libelle_risque_long'].toString().runes.toList());
}).toList();
          setState(() {
            risks = riskNames;
            isLoading = false;
          });
        }
      } else {
        print('Failed to load risks data');
      }
    } catch (e) {
      print('Error fetching risks data: $e');
    }
  }

  void _showAgentSelectionModal(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return StreamBuilder<List<AppUser>>(
          stream: FirebaseServices().getAllAgents(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return const Center(child: Text("Aucun agent trouvé"));
            }

            List<AppUser> agents = snapshot.data!;
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      DropdownButton<AppUser>(
                        isExpanded: true,
                        hint: const Text("Sélectionner un agent"),
                        value: _selectedAgent,
                        onChanged: (AppUser? newValue) {
                          setState(() {
                            _selectedAgent = newValue;
                          });
                        },
                        items: agents
                            .map<DropdownMenuItem<AppUser>>((AppUser agent) {
                          return DropdownMenuItem<AppUser>(
                            value: agent,
                            child: Text('${agent.nom} ${agent.prenom}'),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        readOnly: true,
                        controller: _dateController,
                        decoration: InputDecoration(
                          hintText: 'Sélectionner une date',
                          suffixIcon: IconButton(
                            onPressed: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null &&
                                  pickedDate != _selectedDate) {
                                setState(() {
                                  _selectedDate = pickedDate;
                                  _dateController.text =
                                      DateFormat('dd/MM/yyyy')
                                          .format(_selectedDate);
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_today),
                          ),
                        ),
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null &&
                              pickedDate != _selectedDate) {
                            setState(() {
                              _selectedDate = pickedDate;
                              _dateController.text = DateFormat('dd/MM/yyyy')
                                  .format(_selectedDate);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_selectedAgent != null) {
                            await _scheduleVisit();
                            Navigator.pop(context);
                          }
                        },
                        child: const Text("Programmer une visite"),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _scheduleVisit() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final visite = Visite(
        id: FirebaseFirestore.instance.collection('visites').doc().id,
        annonceId: widget.annonce.id,
        agentId: _selectedAgent!.id,
        userId: currentUser.uid,
        datevisiteId: _selectedDate,
      );

      await FirebaseServices().addVisite(visite);
    } else {
      // Gérer le cas où aucun utilisateur n'est connecté
      print("Aucun utilisateur connecté");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.network(widget.annonce.imageUrl,
              height: 250, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.annonce.titre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.annonce.prix}€',
                  style: const TextStyle(fontSize: 20, color: Colors.green),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.annonce.m2} m²',
                  style: const TextStyle(fontSize: 18),
                ),
                ListTile(
                  leading: Icon(
                      widget.annonce.jardin ? Icons.check : Icons.close,
                      color: widget.annonce.jardin ? Colors.green : Colors.red),
                  title: const Text('Jardin'),
                ),
                ListTile(
                  leading: Icon(
                      widget.annonce.garage ? Icons.check : Icons.close,
                      color: widget.annonce.garage ? Colors.green : Colors.red),
                  title: const Text('Garage'),
                ),
                ListTile(
                  leading: Icon(
                      widget.annonce.fibreOptique ? Icons.check : Icons.close,
                      color: widget.annonce.fibreOptique
                          ? Colors.green
                          : Colors.red),
                  title: const Text('Fibre Optique'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Description:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(widget.annonce.description,
                    style: const TextStyle(fontSize: 16)),
                OutlinedButton.icon(
                  onPressed: () => _showAgentSelectionModal(context),
                  icon: const Icon(Icons.house),
                  label: const Text("Choisir un agent pour la visite"),
                ),
                const Text(
                  'Risques dans la commune :',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Source - api.gouv.fr',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
                ),
                const SizedBox(height: 10,),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: risks
                            .map(
                              (risk) => Text(
                                '- $risk',
                                style: const TextStyle(fontSize: 16),
                              ),
                            )
                            .toList(),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
