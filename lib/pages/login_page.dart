// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:okeys/components/my_button.dart';
import 'package:okeys/components/my_text_field.dart';
import 'package:okeys/colors.dart';
import 'package:okeys/services/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // sign in user
  void signIn() async {
    // get the auth service
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signInWithEmailandPassword(
        emailController.text,
        passwordController.text,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
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
                  const SizedBox(height: 20),
                  //logo
                  Icon(
                    Icons.emoji_people_rounded,
                    size: 100,
                    color: Palette.primary,
                  ),
                  const SizedBox(height: 50),
                  Text(
                    "Bon retour , vous nous aviez manquer",
                    style: TextStyle(fontSize: 16, color: Palette.text),
                  ),
                  const SizedBox(height: 25),

                  MyTextField(
                      controller: emailController,
                      hintText: "Email",
                      obscureText: false,
                      icon: Icons.email),

                  const SizedBox(height: 10),

                  MyTextField(
                      controller: passwordController,
                      hintText: "Mot de passe",
                      obscureText: true,
                      icon: Icons.password),
                  const SizedBox(height: 25),

                  //sign in button

                  MyButton(onTap: signIn, text: "Connexion"),

                  const SizedBox(height: 50),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Pas encore inscrit?",
                          style: TextStyle(
                            color: Palette.text,
                          )),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          "Inscrivez-vous ici",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Palette.secondary,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
