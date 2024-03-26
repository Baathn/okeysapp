import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:okeys/colors.dart';
import 'package:okeys/pages/privatechat_page.dart';
import 'package:okeys/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  late String _username;

  @override
  void initState() {
    super.initState();
  }

  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
  }

  Future<String> getUsername(User user) async {
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return userData['prenom'] ?? "No username";
  }

  Future<String> getAgentName(String agentId) async {
    final agentDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(agentId)
        .get();
    if (agentDoc.exists) {
      return "${agentDoc['prenom']} ${agentDoc['nom']}";
    } else {
      return "Agent inconnu";
    }
  }

  Future<DocumentSnapshot> getAnnonce(String annonceId) async {
    return await FirebaseFirestore.instance
        .collection('annonces')
        .doc(annonceId)
        .get();
  }

  String formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.background,
        appBar: AppBar(
          backgroundColor: Palette.background,
          actions: [
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Builder(
                    builder: (BuildContext context) {
                      return Container(
                        color: Palette.background,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  signOut();
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Deconnexion",
                                      style:
                                          TextStyle(color: Palette.secondary),
                                    ),
                                    Icon(
                                      Icons.logout,
                                      color: Palette.secondary,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              icon: Icon(
                Icons.manage_accounts_rounded,
                color: Palette.primary,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (!snapshot.hasData) {
                        return Text(
                          "User not logged in",
                          style: TextStyle(color: Palette.text),
                        );
                      }
                      final user = snapshot.data!;
                      return FutureBuilder<String>(
                          future: getUsername(user),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (!snapshot.hasData) {
                              return const Text('No data');
                            }
                            _username = snapshot.data!;
                            return Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 30),
                                  Center(
                                    child: Text(
                                      "Bonjour $_username",
                                      style: TextStyle(
                                          color: Palette.text, fontSize: 20),
                                    ),
                                  ),
                                  const SizedBox(height: 80),
                                  Center(
                                    child: Text(
                                      "Visites prévues :",
                                      style: TextStyle(
                                        color: Palette.text,
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    thickness: 2,
                                    color: Palette.primary,
                                    height: 20,
                                    indent: 10,
                                    endIndent: 10,
                                  ),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('visites')
                                        .snapshots(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<QuerySnapshot>
                                            snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      if (snapshot.hasError) {
                                        return Text(
                                            'Error: ${snapshot.error}');
                                      }
                                      if (!snapshot.hasData) {
                                        return const Text('No data');
                                      }
                                      final visits = snapshot.data!.docs;
                                      if (visits.isEmpty) {
                                        return const Text(
                                            'Aucune visite prévue.');
                                      }
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: visits.length,
                                        itemBuilder: (context, index) {
                                          final data =
                                              visits[index].data()
                                                  as Map<String, dynamic>;
                                          final visiteId =
                                              visits[index].id; // ID de la visite
                                          // Vérifier si l'utilisateur est l'agent
                                          if (data['agentId'] == user.uid) {
                                            return FutureBuilder<
                                                    DocumentSnapshot>(
                                                future: getAnnonce(data[
                                                    'annonceId']),
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  }
                                                  if (!snapshot.hasData ||
                                                      !snapshot.data!.exists) {
                                                    return const SizedBox();
                                                  }
                                                  final annonceData =
                                                      snapshot.data!.data()
                                                          as Map<String,
                                                              dynamic>;
                                                  return ListTile(
                                                    leading: Container(
                                                      width: 100,
                                                      height: 100,
                                                      decoration:
                                                          BoxDecoration(
                                                        shape:
                                                            BoxShape.rectangle,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    8.0),
                                                        image:
                                                            DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: NetworkImage(
                                                              annonceData[
                                                                  'imageUrl']),
                                                        ),
                                                      ),
                                                    ),
                                                    title: Text(annonceData[
                                                        'titre']),
                                                    subtitle: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            "Date: ${formatDate(data['datevisiteId'])}"),
                                                        FutureBuilder<String>(
                                                            future: getAgentName(
                                                                data[
                                                                    'agentId']),
                                                            builder: (context,
                                                                snapshot) {
                                                              if (snapshot
                                                                      .connectionState ==
                                                                  ConnectionState
                                                                      .waiting) {
                                                                return const CircularProgressIndicator();
                                                              }
                                                              if (snapshot
                                                                  .hasError) {
                                                                return Text(
                                                                    'Error: ${snapshot.error}');
                                                              }
                                                              if (!snapshot
                                                                  .hasData) {
                                                                return const Text(
                                                                    'Chargement...');
                                                              }
                                                              return Text(
                                                                  "Avec: ${snapshot.data}");
                                                            }),
                                                      ],
                                                    ),
                                                    trailing: IconButton(
                                                      icon: Icon(
                                                        Icons.message,
                                                        color:
                                                            Palette.primary,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                PrivateChatPage(
                                                              userId:
                                                                  user.uid,
                                                              agentId: data[
                                                                  'agentId'],
                                                              visiteId:
                                                                  visiteId,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  );
                                                });
                                          } else {
                                            // Si l'utilisateur n'est pas l'agent, vérifier s'il est le client
                                            if (data['userId'] == user.uid) {
                                              return FutureBuilder<
                                                      DocumentSnapshot>(
                                                  future: getAnnonce(data[
                                                      'annonceId']),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      );
                                                    }
                                                    if (!snapshot.hasData ||
                                                        !snapshot
                                                            .data!.exists) {
                                                      return const SizedBox();
                                                    }
                                                    final annonceData =
                                                        snapshot.data!.data()
                                                            as Map<String,
                                                                dynamic>;
                                                    return ListTile(
                                                      leading: Container(
                                                        width: 100,
                                                        height: 100,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape: BoxShape
                                                              .rectangle,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          image:
                                                              DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image: NetworkImage(
                                                                annonceData[
                                                                    'imageUrl']),
                                                          ),
                                                        ),
                                                      ),
                                                      title: Text(
                                                          annonceData[
                                                              'titre']),
                                                      subtitle: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              "Date: ${formatDate(data['datevisiteId'])}"),
                                                          FutureBuilder<String>(
                                                              future: getAgentName(
                                                                  data[
                                                                      'agentId']),
                                                              builder: (context,
                                                                  snapshot) {
                                                                if (snapshot
                                                                        .connectionState ==
                                                                    ConnectionState
                                                                        .waiting) {
                                                                  return const CircularProgressIndicator();
                                                                }
                                                                if (snapshot
                                                                    .hasError) {
                                                                  return Text(
                                                                      'Error: ${snapshot.error}');
                                                                }
                                                                if (!snapshot
                                                                    .hasData) {
                                                                  return const Text(
                                                                      'Chargement...');
                                                                }
                                                                return Text(
                                                                    "Avec: ${snapshot.data}");
                                                              }),
                                                        ],
                                                      ),
                                                      trailing: IconButton(
                                                        icon: Icon(
                                                          Icons.message,
                                                          color:
                                                              Palette.primary,
                                                        ),
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  PrivateChatPage(
                                                                userId:
                                                                    user.uid,
                                                                agentId: data[
                                                                    'agentId'],
                                                                visiteId:
                                                                    visiteId,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    );
                                                  });
                                            } else {
                                              return const SizedBox();
                                            }
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ],
                              )
                            );
                          });
                    }),
              ],
            ),
          ),
        ),
      );
}
