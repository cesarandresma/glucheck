import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../firebase_options.dart';
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
    if (!kFirebaseConfigured && isFirebaseOptionsPlaceholder) {
      status.value = SplashStatus.firebaseMissing;
      message.value =
          'Firebase aún no está configurado. Siga el README para ejecutar flutterfire configure.';
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
