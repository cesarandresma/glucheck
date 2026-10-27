import 'package:flutter_test/flutter_test.dart';
import 'package:glucotrack/core/utils/glucose_validators.dart';

void main() {
  test('valida valor numérico y advertencia', () {
    expect(GlucoseValidators.validateValue('').isValid, false);
    expect(GlucoseValidators.validateValue('abc').isValid, false);
    expect(GlucoseValidators.validateValue('110').isValid, true);
    expect(GlucoseValidators.validateValue('110').warningMessage, isNull);
    expect(GlucoseValidators.validateValue('50').warningMessage, isNotNull);
  });

  test('valida email y contraseña', () {
    expect(GlucoseValidators.validateEmail('bad'), isNotNull);
    expect(GlucoseValidators.validateEmail('a@b.com'), isNull);
    expect(GlucoseValidators.validatePassword('123'), isNotNull);
    expect(GlucoseValidators.validatePassword('123456'), isNull);
  });
}
