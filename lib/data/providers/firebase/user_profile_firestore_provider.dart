import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/app_exception.dart';
import '../../models/user_profile.dart';
import 'firestore_paths.dart';

class UserProfileFirestoreProvider {
  UserProfileFirestoreProvider(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) {
    return _firestore.doc(FirestorePaths.userDoc(uid));
  }

  Future<UserProfile?> getProfile(String uid) async {
    try {
      final snap = await _doc(uid).get();
      if (!snap.exists || snap.data() == null) return null;
      return UserProfile.fromMap(uid, snap.data()!);
    } on FirebaseException catch (e) {
      throw FirebaseAppException(_message(e));
    }
  }

  Future<void> deleteProfile(String uid) async {
    try {
      await _doc(uid).delete();
    } on FirebaseException catch (e) {
      throw FirebaseAppException(_message(e));
    }
  }

  Future<UserProfile> createOrUpdate(UserProfile profile) async {
    try {
      await _doc(profile.uid).set(profile.toMap(), SetOptions(merge: true));
      return profile;
    } on FirebaseException catch (e) {
      throw FirebaseAppException(_message(e));
    }
  }

  String _message(FirebaseException e) {
    if (e.code == 'permission-denied') {
      return 'No tiene permiso para modificar el perfil.';
    }
    return 'Error al acceder al perfil.';
  }
}
