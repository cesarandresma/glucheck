import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/errors/app_exception.dart';
import '../data/models/user_profile.dart';
import '../data/repositories/glucose_repository.dart';
import '../data/repositories/user_profile_repository.dart';

class AuthService {
  AuthService({
    required FirebaseAuth auth,
    required UserProfileRepository profileRepository,
    required GlucoseRepository glucoseRepository,
    required FlutterSecureStorage secureStorage,
  }) : _auth = auth,
       _profiles = profileRepository,
       _glucose = glucoseRepository,
       _secureStorage = secureStorage;

  final FirebaseAuth _auth;
  final UserProfileRepository _profiles;
  final GlucoseRepository _glucose;
  final FlutterSecureStorage _secureStorage;

  static const _lastUidKey = 'last_session_uid';

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  bool get isAuthenticated => currentUser != null;

  Future<UserProfile?> getCurrentProfile() async {
    final user = currentUser;
    if (user == null) return null;
    return _profiles.getProfile(user.uid);
  }

  Future<UserProfile> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        throw const AuthException('No se pudo crear la cuenta.');
      }
      await user.updateDisplayName(name.trim());
      final now = DateTime.now().toUtc();
      final profile = UserProfile(
        uid: user.uid,
        displayName: name.trim(),
        email: user.email ?? email.trim(),
        createdAt: now,
        updatedAt: now,
      );
      await _profiles.saveProfile(profile);
      await _secureStorage.write(key: _lastUidKey, value: user.uid);
      return profile;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    }
  }

  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        throw const AuthException('No se pudo iniciar sesión.');
      }
      var profile = await _profiles.getProfile(user.uid);
      if (profile == null) {
        final now = DateTime.now().toUtc();
        profile = UserProfile(
          uid: user.uid,
          displayName: user.displayName ?? '',
          email: user.email ?? email.trim(),
          createdAt: now,
          updatedAt: now,
        );
        await _profiles.saveProfile(profile);
      }
      await _secureStorage.write(key: _lastUidKey, value: user.uid);
      return profile;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _secureStorage.delete(key: _lastUidKey);
  }

  /// Reautentica, borra lecturas y perfil propios, y elimina la cuenta de Auth.
  Future<void> deleteAccount(String password) async {
    final user = currentUser;
    final email = user?.email;
    if (user == null || email == null || email.isEmpty) {
      throw const AuthException('Sesión expirada.');
    }
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      await _glucose.deleteAllReadings(user.uid);
      await _profiles.deleteProfile(user.uid);
      await user.delete();
      await _secureStorage.delete(key: _lastUidKey);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    }
  }

  Future<String?> getLastSessionUid() => _secureStorage.read(key: _lastUidKey);

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'invalid-email':
        return 'Correo electrónico no válido.';
      case 'weak-password':
        return 'Contraseña demasiado débil.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intente más tarde.';
      case 'requires-recent-login':
        return 'Vuelva a introducir su contraseña para continuar.';
      case 'cancelled':
      case 'web-context-cancelled':
        return 'Operación cancelada.';
      default:
        return 'Error de autenticación. Intente de nuevo.';
    }
  }
}
