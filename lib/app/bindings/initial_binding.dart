import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../data/providers/firebase/glucose_firestore_provider.dart';
import '../../data/providers/firebase/user_profile_firestore_provider.dart';
import '../../data/providers/local/local_storage_provider.dart';
import '../../data/repositories/glucose_repository.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../services/auth_service.dart';
import '../../services/connectivity_service.dart';
import '../../services/preferences_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<LocalStorageProvider>(LocalStorageProvider(), permanent: true);
    Get.put<ConnectivityService>(
      ConnectivityService(Connectivity()),
      permanent: true,
    );
    Get.put<FirebaseAuth>(FirebaseAuth.instance, permanent: true);
    Get.put<FirebaseFirestore>(FirebaseFirestore.instance, permanent: true);

    Get.lazyPut(
      () => UserProfileFirestoreProvider(Get.find<FirebaseFirestore>()),
      fenix: true,
    );
    Get.lazyPut(
      () => GlucoseFirestoreProvider(Get.find<FirebaseFirestore>()),
      fenix: true,
    );
    Get.lazyPut(
      () => UserProfileRepository(Get.find<UserProfileFirestoreProvider>()),
      fenix: true,
    );
    Get.lazyPut(
      () => GlucoseRepository(
        remote: Get.find<GlucoseFirestoreProvider>(),
        local: Get.find<LocalStorageProvider>(),
        connectivity: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => PreferencesService(Get.find<LocalStorageProvider>()),
      fenix: true,
    );
    Get.put<AuthService>(
      AuthService(
        auth: Get.find<FirebaseAuth>(),
        profileRepository: Get.find<UserProfileRepository>(),
        glucoseRepository: Get.find<GlucoseRepository>(),
        secureStorage: const FlutterSecureStorage(),
      ),
      permanent: true,
    );
  }
}
