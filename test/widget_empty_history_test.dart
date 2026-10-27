import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:glucotrack/core/errors/app_exception.dart';
import 'package:glucotrack/data/repositories/glucose_repository.dart';
import 'package:glucotrack/modules/history/history_controller.dart';
import 'package:glucotrack/modules/history/history_view.dart';
import 'package:glucotrack/services/auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

class MockGlucoseRepository extends Mock implements GlucoseRepository {}

class FakeUser extends Fake implements User {
  @override
  String get uid => 'u1';
}

void main() {
  late MockAuthService auth;
  late MockGlucoseRepository repo;

  setUp(() {
    Get.testMode = true;
    auth = MockAuthService();
    repo = MockGlucoseRepository();
    when(() => auth.currentUser).thenReturn(FakeUser());
  });

  tearDown(Get.reset);

  void stubReadings(Future<GlucoseListResult> Function() body) {
    when(
      () => repo.getReadings(
        userId: any(named: 'userId'),
        from: any(named: 'from'),
        to: any(named: 'to'),
        context: any(named: 'context'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) => body());
    Get.put(HistoryController(repo, auth));
  }

  testWidgets('Historial vacío muestra mensaje', (tester) async {
    stubReadings(
      () async => const GlucoseListResult(readings: [], fromCache: false),
    );
    await tester.pumpWidget(
      const GetMaterialApp(home: Scaffold(body: HistoryView())),
    );
    await tester.pump();

    expect(find.text('Sin registros'), findsOneWidget);
  });

  testWidgets('Historial muestra error y reintento', (tester) async {
    stubReadings(
      () async => throw const NetworkException('Sin conexión y sin caché.'),
    );
    await tester.pumpWidget(
      const GetMaterialApp(home: Scaffold(body: HistoryView())),
    );
    await tester.pump();

    expect(find.text('Sin conexión y sin caché.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });
}
