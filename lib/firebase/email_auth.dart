import 'package:firebase_auth/firebase_auth.dart';

class EmailAuth {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<bool> createUser(String email, String password) async {
    try {
      final credentials = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await credentials.user?.sendEmailVerification();
      return true;
    } catch (e) {
      print("Error creating user: $e");
      return false;
    }
  }

  Future<bool> validateUser(String email, String password) async {
    try {
      final credentials = await auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (credentials.user != null && credentials.user!.emailVerified) {
        return true;
      } else {
        print("Email not verified.");
        return false;
      }
    } catch (e) {
      print("Error validating user: $e");
      return false;
    }
  }

  Future<bool> resendVerificationEmail() async {
    try {
      final user = auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return true;
      }
      return false; // Usuario no disponible o ya verificado
    } catch (e) {
      print("Error resending verification email: $e");
      return false;
    }
  }
}
