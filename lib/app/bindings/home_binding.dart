import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../modules/assistant/assistant_controller.dart';
import '../../modules/auth/auth_controller.dart';
import '../../modules/dashboard/dashboard_controller.dart';
import '../../modules/glucose/glucose_controller.dart';
import '../../modules/history/history_controller.dart';
import '../../modules/home/home_view.dart';
import '../../modules/profile/profile_controller.dart';
import '../../modules/settings/settings_controller.dart';
import '../../modules/statistics/statistics_controller.dart';
import '../../data/providers/local/local_storage_provider.dart';
import '../../data/repositories/glucose_repository.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../services/auth_service.dart';
import '../../services/preferences_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController(Get.find<AuthService>()));
    Get.lazyPut(() => HomeController());
    Get.lazyPut(
      () => DashboardController(
        Get.find<GlucoseRepository>(),
        Get.find<AuthService>(),
      ),
    );
    Get.lazyPut(
      () => HistoryController(
        Get.find<GlucoseRepository>(),
        Get.find<AuthService>(),
      ),
    );
    Get.lazyPut(
      () => StatisticsController(
        Get.find<GlucoseRepository>(),
        Get.find<AuthService>(),
      ),
    );
    Get.lazyPut(
      () => AssistantController(
        Get.find<AuthService>(),
        Get.find<PreferencesService>(),
        Get.find<FirebaseAuth>(),
      ),
    );
    Get.lazyPut(
      () => ProfileController(
        Get.find<AuthService>(),
        Get.find<UserProfileRepository>(),
      ),
    );
    Get.lazyPut(
      () => SettingsController(
        Get.find<PreferencesService>(),
        Get.find<AuthService>(),
        Get.find<GlucoseRepository>(),
        Get.find<LocalStorageProvider>(),
      ),
    );
    Get.lazyPut(
      () => GlucoseController(
        Get.find<GlucoseRepository>(),
        Get.find<AuthService>(),
      ),
    );
  }
}
