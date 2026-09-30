import 'dart:async';
import 'dart:developer' as developer;

import '../domain/notification_engine.dart';

/// Calls [NotificationEngine.run] on a timer while the app is open. Runs
/// never overlap; a request during a run schedules one more run after it.
class NotificationScheduler {
  NotificationScheduler(
    this._engine, {
    this.interval = const Duration(minutes: 1),
    this.debounce = const Duration(seconds: 2),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final NotificationEngine _engine;
  final Duration interval;
  final Duration debounce;
  final DateTime Function() _clock;

  Timer? _ticker;
  Timer? _pending;
  bool _running = false;
  bool _runAgain = false;
  bool _disposed = false;

  void start() {
    _ticker ??= Timer.periodic(interval, (_) => run());
    requestRun();
  }

  /// Runs soon, coalescing bursts of changes into one run.
  void requestRun() {
    if (_disposed) return;
    _pending?.cancel();
    _pending = Timer(debounce, run);
  }

  Future<void> run() async {
    if (_disposed) return;
    if (_running) {
      _runAgain = true;
      return;
    }
    _running = true;
    try {
      await _engine.run(_clock());
    } catch (error, stackTrace) {
      developer.log(
        'Notification run failed',
        name: 'notifications',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _running = false;
      if (_runAgain && !_disposed) {
        _runAgain = false;
        unawaited(run());
      }
    }
  }

  void dispose() {
    _disposed = true;
    _ticker?.cancel();
    _pending?.cancel();
  }
}
