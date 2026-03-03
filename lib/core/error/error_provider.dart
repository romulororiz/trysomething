import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'error_reporter.dart';

/// Global singleton error reporter.
final errorReporterProvider = Provider<ErrorReporter>((ref) {
  return ErrorReporter();
});

/// Riverpod observer that reports provider errors to [ErrorReporter].
class ErrorReporterObserver extends ProviderObserver {
  final ErrorReporter reporter;

  ErrorReporterObserver(this.reporter);

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    reporter.reportError(
      error,
      stackTrace,
      context: 'Provider: ${provider.name ?? provider.runtimeType.toString()}',
    );
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // Log async error states
    if (newValue is AsyncError) {
      reporter.reportError(
        newValue.error,
        newValue.stackTrace,
        context: 'AsyncProvider: ${provider.name ?? provider.runtimeType.toString()}',
      );
    }
  }
}
