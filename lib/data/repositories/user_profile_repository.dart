import '../../core/errors/app_exception.dart';
import '../models/user_profile.dart';
import '../providers/firebase/user_profile_firestore_provider.dart';

class UserProfileRepository {
  UserProfileRepository(this._remote);

  final UserProfileFirestoreProvider _remote;

  Future<UserProfile?> getProfile(String uid) => _remote.getProfile(uid);

  Future<UserProfile> saveProfile(UserProfile profile) =>
      _remote.createOrUpdate(profile);

  Future<void> deleteProfile(String uid) => _remote.deleteProfile(uid);

  Future<UserProfile> updateDisplayName({
    required UserProfile current,
    required String displayName,
  }) async {
    if (displayName.trim().length < 2) {
      throw const ValidationException('Nombre demasiado corto.');
    }
    final updated = current.copyWith(
      displayName: displayName.trim(),
      updatedAt: DateTime.now().toUtc(),
    );
    return _remote.createOrUpdate(updated);
  }
}
