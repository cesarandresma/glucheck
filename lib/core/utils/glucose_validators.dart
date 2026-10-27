import '../constants/app_constants.dart';
import '../constants/measurement_contexts.dart';

class GlucoseValidationResult {
  const GlucoseValidationResult({
    required this.isValid,
    this.errorMessage,
    this.warningMessage,
  });

  final bool isValid;
  final String? errorMessage;
  final String? warningMessage;
}

class GlucoseValidators {
  GlucoseValidators._();

  static GlucoseValidationResult validateValue(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const GlucoseValidationResult(
        isValid: false,
        errorMessage: 'Ingrese el valor de glucosa.',
      );
    }
    final normalized = raw.replaceAll(',', '.');
    final value = double.tryParse(normalized);
    if (value == null) {
      return const GlucoseValidationResult(
        isValid: false,
        errorMessage: 'El valor debe ser numérico.',
      );
    }
    if (value < AppConstants.glucoseMinMgDl ||
        value > AppConstants.glucoseMaxMgDl) {
      return GlucoseValidationResult(
        isValid: false,
        errorMessage:
            'Use un valor entre ${AppConstants.glucoseMinMgDl.toInt()} y '
            '${AppConstants.glucoseMaxMgDl.toInt()} mg/dL.',
      );
    }
    String? warning;
    if (value < AppConstants.glucoseTypicalLowMgDl ||
        value > AppConstants.glucoseTypicalHighMgDl) {
      warning =
          'Valor fuera del rango habitual de referencia. Verifique la medición '
          'y consulte a su profesional de salud si tiene dudas.';
    }
    return GlucoseValidationResult(isValid: true, warningMessage: warning);
  }

  static String? validateContext(String? context) {
    if (context == null || !MeasurementContexts.all.contains(context)) {
      return 'Seleccione un contexto de medición.';
    }
    return null;
  }

  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Ingrese su correo electrónico.';
    }
    final pattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!pattern.hasMatch(email.trim())) {
      return 'Correo electrónico no válido.';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Ingrese su contraseña.';
    }
    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return null;
  }

  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Ingrese su nombre.';
    }
    if (name.trim().length < 2) {
      return 'El nombre es demasiado corto.';
    }
    if (name.trim().length > AppConstants.displayNameMaxLength) {
      return 'El nombre es demasiado largo.';
    }
    return null;
  }

  static String? validateNotes(String? notes) {
    if (notes == null || notes.trim().isEmpty) return null;
    if (notes.trim().length > AppConstants.notesMaxLength) {
      return 'Las notas superan los ${AppConstants.notesMaxLength} caracteres.';
    }
    return null;
  }
}
