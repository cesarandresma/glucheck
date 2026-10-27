import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:glucotrack/data/repositories/glucose_repository.dart';
import 'package:glucotrack/modules/glucose/glucose_controller.dart';
import 'package:glucotrack/modules/glucose/glucose_form_view.dart';
import 'package:glucotrack/services/auth_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

class MockGlucoseRepository extends Mock implements GlucoseRepository {}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  setUp(() {
    Get.testMode = true;
    Get.put(GlucoseController(MockGlucoseRepository(), MockAuthService()));
  });

  tearDown(Get.reset);

  testWidgets('formulario vacío muestra el error de validación', (
    tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: GlucoseFormView()));

    await tester.tap(find.text('Guardar'));
    await tester.pump();

    expect(find.text('Ingrese el valor de glucosa.'), findsOneWidget);
  });
}
