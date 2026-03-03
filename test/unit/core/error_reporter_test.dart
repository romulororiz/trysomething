import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/core/error/error_reporter.dart';

void main() {
  group('ErrorReporter', () {
    late ErrorReporter reporter;

    setUp(() {
      reporter = ErrorReporter();
    });

    test('starts with empty errors list', () {
      expect(reporter.errors, isEmpty);
    });

    test('reportError adds to errors list', () {
      reporter.reportError(Exception('test'), StackTrace.current);
      expect(reporter.errors, hasLength(1));
      expect(reporter.errors.first.error.toString(), contains('test'));
    });

    test('reportError stores context', () {
      reporter.reportError(
        Exception('ctx'),
        null,
        context: 'TestContext',
      );
      expect(reporter.errors.first.context, 'TestContext');
    });

    test('reportError caps at 50 errors (ring buffer)', () {
      for (int i = 0; i < 60; i++) {
        reporter.reportError(Exception('error_$i'), null);
      }
      expect(reporter.errors, hasLength(50));
      // Oldest errors should be dropped
      expect(reporter.errors.first.error.toString(), contains('error_10'));
      expect(reporter.errors.last.error.toString(), contains('error_59'));
    });

    test('reportError records timestamp', () {
      final before = DateTime.now();
      reporter.reportError(Exception('ts'), null);
      final after = DateTime.now();
      final ts = reporter.errors.first.timestamp;
      expect(ts.isAfter(before) || ts.isAtSameMomentAs(before), isTrue);
      expect(ts.isBefore(after) || ts.isAtSameMomentAs(after), isTrue);
    });

    test('ErrorReport toString includes context', () {
      final report = ErrorReport(
        error: Exception('test'),
        timestamp: DateTime(2026, 1, 1),
        context: 'MyCtx',
      );
      expect(report.toString(), contains('MyCtx'));
      expect(report.toString(), contains('test'));
    });

    test('ErrorReport toString without context', () {
      final report = ErrorReport(
        error: Exception('plain'),
        timestamp: DateTime(2026, 1, 1),
      );
      expect(report.toString(), contains('plain'));
      expect(report.toString(), isNot(contains('('))); // no context parens
    });
  });
}
