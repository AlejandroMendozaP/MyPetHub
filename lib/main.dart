import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mypethub/firebase_options.dart';
import 'package:mypethub/provider/theme_provider.dart';
import 'package:mypethub/screens/edit_profile_screen.dart';
import 'package:mypethub/screens/email_verification.dart';
import 'package:mypethub/screens/login_screen.dart';
import 'package:mypethub/screens/maps_screen.dart';
import 'package:mypethub/screens/onboarding_screen.dart';
import 'package:mypethub/screens/pet_detail_screen.dart';
import 'package:mypethub/screens/principal_screen.dart';
import 'package:mypethub/screens/register_screen.dart';
import 'package:mypethub/screens/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://wyfcbhyngmdwuhstieiw.supabase.co', //URL de Supabase
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind5ZmNiaHluZ21kd3Voc3RpZWl3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE5ODU1MjcsImV4cCI6MjA0NzU2MTUyN30.gb-lAyq2pl8by3yr74G96bRkeUyuPqLvtYbxGBUv2QM', // clave pública (anon key)
  );
  runApp(ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MainApp(),
    ),);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),//WelcomeScreen(),
      routes: {
        "/login" : (context) => LoginScreen(),
        "/register" : (context) => RegisterScreen(),
        "/onboarding" : (context) => OnboardingScreen(),
        "/email" : (context) => EmailVerification(),
        "/principal" : (context) => PrincipalScreen(),
        "/editprofile" : (context) => EditProfileScreen(),
      },
    );
  }
}
