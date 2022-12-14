import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quoter/services/category_service.dart';
import 'package:quoter/services/database_services.dart';

abstract class AuthBase {
  User? get currentUser;
  Stream<User?> authStateChanges();
  Future<UserCredential?> signInWithGoogle();
  Future<void> signOut();
}

class Auth implements AuthBase {
  final _firebaseAuth = FirebaseAuth.instance;

  @override
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    dynamic userCredentails =
        await FirebaseAuth.instance.signInWithCredential(credential);
    print("User sign inned...");
    UserQuoteDatabaseService(uid: currentUser!.uid).insertDummyUserData(
      currentUser!.displayName.toString(),
    );
    CategoryService(uid: currentUser!.uid).insertDummyCategory();
    return userCredentails;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
