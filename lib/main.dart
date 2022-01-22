import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:train2/screens/mainscreen.dart';
import 'package:train2/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:train2/screens/register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp( MultiProvider(providers: [
    Provider<AuthService>(
      create: (_) => AuthService(FirebaseAuth.instance),
    ),
    StreamProvider(
      create: (context) => context.read<AuthService>().authStateChanges, initialData: null,
    ),
  ], child:  MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        'register': (context) => MyRegister(),
      },
      debugShowCheckedModeBanner: false,
        title: "APP",
        home: AuthWrapper(),
      );
  }
}

class AuthWrapper extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MainScreen();
  }

}
