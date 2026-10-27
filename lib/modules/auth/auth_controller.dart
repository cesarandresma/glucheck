import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/glucose_validators.dart';
import '../../data/models/user_profile.dart';
import '../../services/auth_service.dart';

class AuthController extends GetxController {
  AuthController(this._auth);

  final AuthService _auth;

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final profile = Rxn<UserProfile>();

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final nameError = GlucoseValidators.validateName(name);
    final emailError = GlucoseValidators.validateEmail(email);
    final passError = GlucoseValidators.validatePassword(password);
    if (nameError != null || emailError != null || passError != null) {
      errorMessage.value = nameError ?? emailError ?? passError;
      return;
    }
    await _run(() async {
      profile.value = await _auth.register(
        name: name,
        email: email,
        password: password,
      );
      Get.offAllNamed(AppRoutes.home);
    });
  }

  Future<void> login({required String email, required String password}) async {
    final emailError = GlucoseValidators.validateEmail(email);
    final passError = GlucoseValidators.validatePassword(password);
    if (emailError != null || passError != null) {
      errorMessage.value = emailError ?? passError;
      return;
    }
    await _run(() async {
      profile.value = await _auth.signIn(email: email, password: password);
      Get.offAllNamed(AppRoutes.home);
    });
  }

  Future<void> resetPassword(String email) async {
    final emailError = GlucoseValidators.validateEmail(email);
    if (emailError != null) {
      errorMessage.value = emailError;
      return;
    }
    await _run(() async {
      await _auth.sendPasswordReset(email);
      Get.snackbar(
        'Correo enviado',
        'Revise su bandeja para restablecer la contraseña.',
      );
    });
  }

  Future<void> logout() async {
    await _auth.signOut();
    profile.value = null;
    Get.offAllNamed(AppRoutes.welcome);
  }

  Future<void> _run(Future<void> Function() action) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await action();
    } on AuthException catch (e) {
      errorMessage.value = e.message;
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Ocurrió un error inesperado.';
    } finally {
      isLoading.value = false;
    }
  }
}
