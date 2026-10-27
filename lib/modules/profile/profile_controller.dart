import 'package:get/get.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../services/auth_service.dart';

class ProfileController extends GetxController {
  ProfileController(this._auth, this._profiles);

  final AuthService _auth;
  final UserProfileRepository _profiles;

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final profile = Rxn<UserProfile>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      profile.value = await _auth.getCurrentProfile();
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateName(String name) async {
    final current = profile.value;
    if (current == null) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      profile.value = await _profiles.updateDisplayName(
        current: current,
        displayName: name,
      );
      Get.snackbar('Perfil', 'Nombre actualizado.');
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }
}
