import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../models/glucose_reading.dart';
import 'firestore_paths.dart';

class GlucoseFirestoreProvider {
  GlucoseFirestoreProvider(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection(FirestorePaths.userReadings(userId));
  }

  Future<List<GlucoseReading>> fetchReadings({
    required String userId,
    DateTime? from,
    DateTime? to,
    String? context,
    int limit = AppConstants.defaultPageSize,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _collection(
        userId,
      ).orderBy('measuredAt', descending: true).limit(limit);

      if (from != null) {
        query = query.where(
          'measuredAt',
          isGreaterThanOrEqualTo: from.toUtc().millisecondsSinceEpoch,
        );
      }
      if (to != null) {
        query = query.where(
          'measuredAt',
          isLessThanOrEqualTo: to.toUtc().millisecondsSinceEpoch,
        );
      }
      if (context != null && context.isNotEmpty) {
        query = query.where('context', isEqualTo: context);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((d) => GlucoseReading.fromMap(d.id, d.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw FirebaseAppException(_mapFirebaseMessage(e));
    }
  }

  Future<GlucoseReading> create(GlucoseReading reading) async {
    try {
      final ref = _collection(reading.userId).doc(reading.id);
      await ref.set(reading.toMap());
      return reading;
    } on FirebaseException catch (e) {
      throw FirebaseAppException(_mapFirebaseMessage(e));
    }
  }

  Future<GlucoseReading> update(GlucoseReading reading) async {
    try {
      await _collection(reading.userId).doc(reading.id).update(reading.toMap());
      return reading;
    } on FirebaseException catch (e) {
      throw FirebaseAppException(_mapFirebaseMessage(e));
    }
  }

  Future<void> delete({
    required String userId,
    required String readingId,
  }) async {
    try {
      await _collection(userId).doc(readingId).delete();
    } on FirebaseException catch (e) {
      throw FirebaseAppException(_mapFirebaseMessage(e));
    }
  }

  Future<void> deleteAll(String userId) async {
    try {
      while (true) {
        final snap = await _collection(userId).limit(200).get();
        if (snap.docs.isEmpty) return;
        final batch = _firestore.batch();
        for (final doc in snap.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } on FirebaseException catch (e) {
      throw FirebaseAppException(_mapFirebaseMessage(e));
    }
  }

  Future<GlucoseReading?> getById({
    required String userId,
    required String readingId,
  }) async {
    try {
      final doc = await _collection(userId).doc(readingId).get();
      if (!doc.exists || doc.data() == null) return null;
      return GlucoseReading.fromMap(doc.id, doc.data()!);
    } on FirebaseException catch (e) {
      throw FirebaseAppException(_mapFirebaseMessage(e));
    }
  }

  String _mapFirebaseMessage(FirebaseException e) {
    if (e.code == 'permission-denied') {
      return 'No tiene permiso para acceder a estos datos.';
    }
    if (e.code == 'unavailable') {
      return 'Servicio no disponible. Intente más tarde.';
    }
    return 'Error al acceder a los datos. Intente de nuevo.';
  }
}
