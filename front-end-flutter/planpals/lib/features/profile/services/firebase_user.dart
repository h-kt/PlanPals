import 'package:firebase_auth/firebase_auth.dart';

class FirebaseUserService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  User? get currentUser => _currentUser;

  Future<void> signOut() => _firebaseAuth.signOut();

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
    return null;
  }

  Future<User?> signUp(String email, String password) async {
    try {
      print('signUp: $email, $password');

      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      print('UserCredential: $userCredential');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
