import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../services/auth_service.dart';

enum SplashStatus { loading, ready, firebaseMissing }

class SplashController extends GetxController {
  SplashController(this._auth);

  final AuthService _auth;

  final status = SplashStatus.loading.obs;
  final message = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (Firebase.apps.isEmpty) {
      status.value = SplashStatus.firebaseMissing;
      message.value =
          'Firebase no está inicializado. Compruebe que android/app/google-services.json '
          'existe en este equipo y vuelva a compilar la app.';
      return;
    }
    status.value = SplashStatus.ready;
    if (_auth.isAuthenticated) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.welcome);
    }
  }

  void continueWithoutFirebaseCheck() {
    if (_auth.isAuthenticated) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.welcome);
    }
  }
}
