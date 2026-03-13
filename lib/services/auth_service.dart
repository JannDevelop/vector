import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Вход по Email и паролю
  Future<String?> signIn(String email, String password) async {
   try {
  await _auth.signInWithEmailAndPassword(email: email, password: password);
  return null;
} on FirebaseAuthException catch (e) {
  print("Код ошибки: ${e.code}"); 
  return e.message;
  }
  }

  // Выход
  Future<void> signOut() async => await _auth.signOut();
}