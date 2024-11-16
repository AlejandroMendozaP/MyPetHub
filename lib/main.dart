import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mypethub/firebase_options.dart';
import 'package:mypethub/screens/email_verification.dart';
import 'package:mypethub/screens/login_screen.dart';
import 'package:mypethub/screens/onboarding_screen.dart';
import 'package:mypethub/screens/register_screen.dart';
import 'package:mypethub/screens/welcome_screen.dart';

void main() async {
  runApp(const MainApp());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),//WelcomeScreen(),
      routes: {
        "/login" : (context) => LoginScreen(),
        "/register" : (context) => RegisterScreen(),
        "/onboarding" : (context) => OnboardingScreen(),
        "/email" : (context) => EmailVerification()
      },
    );
  }
}
