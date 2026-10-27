import 'package:get/get.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/glucose_validators.dart';
import '../../data/models/glucose_reading.dart';
import '../../data/repositories/glucose_repository.dart';
import '../../services/auth_service.dart';

class GlucoseController extends GetxController {
  GlucoseController(this._repo, this._auth);

  final GlucoseRepository _repo;
  final AuthService _auth;

  final isSaving = false.obs;
  final errorMessage = RxnString();
  final warningMessage = RxnString();

  GlucoseReading? editing;

  void setEditing(GlucoseReading? reading) {
    editing = reading;
  }

  void validateValueField(String value) {
    final result = GlucoseValidators.validateValue(value);
    warningMessage.value = result.warningMessage;
  }

  Future<bool> save({
    required String valueText,
    required DateTime measuredAt,
    required String context,
    String? notes,
  }) async {
    final validation = GlucoseValidators.validateValue(valueText);
    if (!validation.isValid) {
      errorMessage.value = validation.errorMessage;
      return false;
    }
    final contextError = GlucoseValidators.validateContext(context);
    if (contextError != null) {
      errorMessage.value = contextError;
      return false;
    }
    final notesError = GlucoseValidators.validateNotes(notes);
    if (notesError != null) {
      errorMessage.value = notesError;
      return false;
    }
    if (isSaving.value) return false;
    final user = _auth.currentUser;
    if (user == null) {
      errorMessage.value = 'Sesión expirada.';
      return false;
    }
    isSaving.value = true;
    errorMessage.value = null;
    try {
      if (editing != null) {
        final updated = editing!.copyWith(
          valueMgDl: double.parse(valueText.replaceAll(',', '.')),
          measuredAt: measuredAt.toUtc(),
          context: context,
          notes: notes,
        );
        await _repo.updateReading(updated);
      } else {
        await _repo.addReading(
          userId: user.uid,
          valueMgDl: double.parse(valueText.replaceAll(',', '.')),
          measuredAt: measuredAt,
          context: context,
          notes: notes,
        );
      }
      return true;
    } on AppException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (_) {
      errorMessage.value = 'No se pudo guardar la medición.';
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteReading(GlucoseReading reading) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    try {
      await _repo.deleteReading(userId: user.uid, readingId: reading.id);
      return true;
    } on AppException catch (e) {
      errorMessage.value = e.message;
      return false;
    }
  }
}
