import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../../modelo/user.dart';
import '../interfaces/i_auth_service.dart';
import '../interfaces/i_user_repository.dart';

/// Firebase implementation of IAuthService
class FirebaseAuthService implements IAuthService {
  final firebase_auth.FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final IUserRepository _userRepository;

  FirebaseAuthService({
    firebase_auth.FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    required IUserRepository userRepository,
  }) : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(),
       _userRepository = userRepository;

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return null;
      }

      // Fetch user data from Firestore
      return await _userRepository.getUserById(credential.user!.uid);
    } on firebase_auth.FirebaseAuthException {
      // Re-throw FirebaseAuthException to preserve error codes
      rethrow;
    } catch (e) {
      throw Exception('Error signing in: $e');
    }
  }

  @override
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // User cancelled
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        return null;
      }

      final firebaseUser = userCredential.user!;

      // Check if user exists in Firestore
      User? existingUser = await _userRepository.getUserById(firebaseUser.uid);

      if (existingUser == null) {
        // Create new user (customers only via app registration)
        final newUser = User(
          id: firebaseUser.uid,
          email: firebaseUser.email!,
          name: firebaseUser.displayName ?? 'Usuario',
          role: UserRole.customer,
        );

        await _userRepository.createUser(newUser);
        return newUser;
      }

      return existingUser;
    } on firebase_auth.FirebaseAuthException {
      // Re-throw FirebaseAuthException to preserve error codes
      rethrow;
    } catch (e) {
      throw Exception('Error signing in with Google: $e');
    }
  }

  @override
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? address,
  }) async {
    try {
      // Check if email already exists
      final emailExists = await _userRepository.checkEmailExists(email);
      if (emailExists) {
        throw Exception('El correo electrónico ya está registrado');
      }

      // Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Error al crear usuario');
      }

      // Update display name
      await credential.user!.updateDisplayName(name);

      // Create user in Firestore (customers only)
      final newUser = User(
        id: credential.user!.uid,
        email: email,
        name: name,
        role: UserRole.customer,
        phone: phone,
        address: address,
      );

      await _userRepository.createUser(newUser);

      return newUser;
    } on firebase_auth.FirebaseAuthException {
      // Re-throw FirebaseAuthException to preserve error codes
      rethrow;
    } catch (e) {
      throw Exception('Error al registrarse: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;

      if (firebaseUser == null) {
        return null;
      }

      return await _userRepository.getUserById(firebaseUser.uid);
    } catch (e) {
      throw Exception('Error getting current user: $e');
    }
  }

  @override
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  @override
  bool isAuthenticated() {
    return _auth.currentUser != null;
  }

  @override
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }
      return await _userRepository.getUserById(firebaseUser.uid);
    });
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException {
      // Re-throw FirebaseAuthException to preserve error codes
      rethrow;
    } catch (e) {
      throw Exception('Error sending password reset email: $e');
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      await user.updatePassword(newPassword);
    } on firebase_auth.FirebaseAuthException {
      // Re-throw FirebaseAuthException to preserve error codes
      rethrow;
    } catch (e) {
      throw Exception('Error updating password: $e');
    }
  }
}
