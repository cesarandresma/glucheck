import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:glucotrack/data/models/user_profile.dart';
import 'package:glucotrack/modules/auth/auth_controller.dart';
import 'package:glucotrack/services/auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService auth;
  late AuthController controller;

  setUp(() {
    Get.testMode = true;
    auth = MockAuthService();
    controller = AuthController(auth);
  });

  tearDown(() {
    Get.reset();
  });

  test('login muestra error de validación', () async {
    await controller.login(email: 'bad', password: '123');
    expect(controller.errorMessage.value, isNotNull);
    verifyNever(
      () => auth.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  test('login exitoso asigna perfil', () async {
    final profile = UserProfile(
      uid: '1',
      displayName: 'Ana',
      email: 'a@b.com',
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    when(
      () => auth.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => profile);

    await controller.login(email: 'a@b.com', password: '123456');
    expect(controller.profile.value?.displayName, 'Ana');
  });
}
