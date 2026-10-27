import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:glucotrack/modules/auth/welcome_view.dart';

void main() {
  testWidgets('Pantalla de bienvenida muestra GlucoTrack', (tester) async {
    Get.testMode = true;
    await tester.pumpWidget(const GetMaterialApp(home: WelcomeView()));
    expect(find.text('GlucoTrack'), findsOneWidget);
  });
}
