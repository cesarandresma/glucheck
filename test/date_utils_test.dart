import 'package:flutter_test/flutter_test.dart';
import 'package:glucotrack/core/utils/date_utils_app.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  test('formatea fecha hora local', () {
    final dt = DateTime(2025, 3, 10, 14, 5);
    final formatted = DateUtilsApp.formatDateTime(dt);
    expect(formatted, contains('2025'));
    expect(formatted, contains('14:05'));
  });
}
