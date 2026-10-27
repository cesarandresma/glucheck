import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:glucotrack/modules/auth/auth_controller.dart';
import 'package:glucotrack/modules/auth/login_view.dart';
import 'package:glucotrack/services/auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  tearDown(Get.reset);

  testWidgets('LoginView muestra campos', (tester) async {
    final auth = MockAuthService();
    Get.testMode = true;
    Get.put<AuthController>(AuthController(auth));

    await tester.pumpWidget(GetMaterialApp(home: LoginView()));

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
  });
}
