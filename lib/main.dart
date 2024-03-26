import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:okeys/pages/annonces_page.dart';
import 'package:okeys/pages/estimation_page.dart';
import 'package:okeys/pages/upload_page.dart';
import 'package:okeys/pages/visite_page.dart';
import 'package:provider/provider.dart';
import 'package:okeys/firebase_options.dart';
import 'package:okeys/services/auth/auth_gate.dart';
import 'package:okeys/services/auth/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
        routes: <String, WidgetBuilder>{
          '/auth': (BuildContext context) => const AuthGate(),
          '/upload': (BuildContext context) => const UploadPage(),
          '/annonces': (BuildContext context) => const AnnoncePage(),
          '/estimation': (BuildContext context) => const EstimationPage(),
          '/visite': (BuildContext context) => const VisitePage(),
        });
  }
}
