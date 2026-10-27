import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucotrack/core/constants/measurement_contexts.dart';
import 'package:glucotrack/data/providers/firebase/glucose_firestore_provider.dart';
import 'package:glucotrack/data/providers/local/local_storage_provider.dart';
import 'package:glucotrack/data/repositories/glucose_repository.dart';
import 'package:glucotrack/services/connectivity_service.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalStorage extends Mock implements LocalStorageProvider {}

class MockConnectivity extends Mock implements ConnectivityService {}

class MockReadingsBox extends Mock implements Box<dynamic> {}

void main() {
  test('repositorio crea lectura en firestore fake', () async {
    final firestore = FakeFirebaseFirestore();
    final remote = GlucoseFirestoreProvider(firestore);
    final local = MockLocalStorage();
    final box = MockReadingsBox();
    final connectivity = MockConnectivity();
    when(() => connectivity.isOnline).thenAnswer((_) async => true);
    when(() => local.openUserReadingsBox('u1')).thenAnswer((_) async => box);
    when(() => box.get(GlucoseRepository.cacheKey)).thenReturn(null);
    when(() => box.put(any(), any())).thenAnswer((_) async {});

    final repo = GlucoseRepository(
      remote: remote,
      local: local,
      connectivity: connectivity,
    );

    final measuredAt = DateTime.utc(2025, 2, 1, 8);
    final saved = await repo.addReading(
      userId: 'u1',
      valueMgDl: 105,
      measuredAt: measuredAt,
      context: MeasurementContexts.fasting,
    );
    final list = await remote.fetchReadings(userId: 'u1');
    expect(list.length, 1);
    expect(saved.valueMgDl, 105);
    expect(list.first.valueMgDl, 105);
  });
}
