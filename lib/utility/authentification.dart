import 'package:firebase_auth/firebase_auth.dart';
import 'package:restaurant_mangement/utility/toast.dart';

FirebaseAuth fbAuth = FirebaseAuth.instance;

void createUser(String email, String pass, String displayName) async {
  try {
    final UserCredential credential =
        await fbAuth.createUserWithEmailAndPassword(
      email: email,
      password: pass,
    );
    await credential.user!.updateDisplayName(displayName);
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      showToast('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      showToast('The account already exists for that email.');
    }
  } catch (e) {
    showToast(e.toString());
  }
}

Future<void> signIn(String email, String pass) async {
  try {
    final credential =
        await fbAuth.signInWithEmailAndPassword(email: email, password: pass);
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      showToast('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      showToast('Wrong password provided for that user.');
    }
  }
}

Future<void> signOut() async {
  fbAuth.signOut();
}

bool isSIgnedIn() {
  return fbAuth.currentUser != null;
}
