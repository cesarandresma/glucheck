import 'package:get/get.dart';

import '../../modules/auth/auth_controller.dart';
import '../../modules/auth/forgot_password_view.dart';
import '../../modules/auth/login_view.dart';
import '../../modules/auth/register_view.dart';
import '../../modules/auth/welcome_view.dart';
import '../../modules/glucose/glucose_controller.dart';
import '../../modules/glucose/glucose_form_view.dart';
import '../../modules/home/home_view.dart';
import '../../modules/settings/privacy_view.dart';
import '../../modules/splash/splash_controller.dart';
import '../../modules/splash/splash_view.dart';
import '../../services/auth_service.dart';
import '../bindings/home_binding.dart';
import 'app_routes.dart';
import 'auth_middleware.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SplashController(Get.find<AuthService>()));
      }),
    ),
    GetPage(
      name: AppRoutes.welcome,
      page: () => const WelcomeView(),
      middlewares: [GuestMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController(Get.find()));
      }),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
      middlewares: [GuestMiddleware()],
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AuthController>()) {
          Get.lazyPut(() => AuthController(Get.find()));
        }
      }),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => RegisterView(),
      middlewares: [GuestMiddleware()],
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AuthController>()) {
          Get.lazyPut(() => AuthController(Get.find()));
        }
      }),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => ForgotPasswordView(),
      middlewares: [GuestMiddleware()],
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AuthController>()) {
          Get.lazyPut(() => AuthController(Get.find()));
        }
      }),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.addGlucose,
      page: () => const GlucoseFormView(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<GlucoseController>()) {
          Get.lazyPut(() => GlucoseController(Get.find(), Get.find()));
        }
      }),
    ),
    GetPage(
      name: AppRoutes.editGlucose,
      page: () => const GlucoseFormView(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<GlucoseController>()) {
          Get.lazyPut(() => GlucoseController(Get.find(), Get.find()));
        }
      }),
    ),
    GetPage(
      name: AppRoutes.privacy,
      page: () => const PrivacyView(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
