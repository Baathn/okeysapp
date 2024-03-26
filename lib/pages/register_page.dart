// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:okeys/colors.dart';
import 'package:okeys/components/my_button.dart';
import 'package:okeys/components/my_text_field.dart';
import 'package:okeys/services/firebase_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({Key? key, required this.onTap}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nomController.dispose();
    prenomController.dispose();
    super.dispose();
  }

  void signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Les mots de passe ne correspondent pas !")),
      );
      return;
    }

    // Instance de FirebaseServices
    final firebaseServices = FirebaseServices();

    try {
      final user = await firebaseServices.signUp(
        email: emailController.text,
        password: passwordController.text,
        nom: nomController.text,
        prenom: prenomController.text,
      );

      if (user != null) {
        // Inscription réussie, naviguer vers l'écran d'accueil ou autre
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Inscription réussie !")),
        );
      } else {
        // Échec de l'inscription, afficher un message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Échec de l'inscription")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Erreur lors de l'inscription : ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  // Logo
                  Icon(
                    Icons.accessibility_new_rounded,
                    size: 100,
                    color: Palette.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Créons un compte pour vous !",
                    style: TextStyle(fontSize: 16, color: Palette.text),
                  ),
                  const SizedBox(height: 20),
                  //Email
                  MyTextField(
                      controller: emailController,
                      hintText: "Email",
                      obscureText: false,
                      icon: Icons.mail,
                      maxLength: 50),
                  Divider(color: Palette.secondary),
                  const SizedBox(height: 20),
                  //Mot de passe
                  MyTextField(
                      controller: passwordController,
                      hintText: "Mot de passe",
                      obscureText: true,
                      icon: Icons.password,
                      maxLength: 50),
                  const SizedBox(height: 10),
                  MyTextField(
                      controller: confirmPasswordController,
                      hintText: "Confirmer le mot de passe",
                      obscureText: true,
                      icon: Icons.password,
                      maxLength: 50),
                  Divider(color: Palette.secondary),
                  const SizedBox(height: 20),
                  //Nom et prénom
                  MyTextField(
                      controller: nomController,
                      hintText: "Nom",
                      obscureText: false,
                      icon: Icons.abc_outlined,
                      maxLength: 50),
                  const SizedBox(width: 10),
                  MyTextField(
                      controller: prenomController,
                      hintText: "Prénom",
                      obscureText: false,
                      icon: Icons.abc_outlined,
                      maxLength: 50),
                  Divider(color: Palette.secondary),
                  const SizedBox(height: 50),
                  //Bouton d'inscription
                  MyButton(onTap: signUp, text: "S'inscrire"),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Déjà membre ?",
                          style: TextStyle(color: Palette.text)),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          "Se connecter ici",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Palette.secondary),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
