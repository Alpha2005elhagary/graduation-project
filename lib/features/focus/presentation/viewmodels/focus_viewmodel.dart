import 'package:breakbot/core/utils/failure.dart';
import 'package:breakbot/features/focus/domain/entities/focus_session.dart';
import 'package:breakbot/features/focus/domain/usecases/focus_usecases.dart';
import 'package:breakbot/shared/models/base_viewmodel.dart';

class FocusViewModel extends BaseViewModel {
  final StartFocusSessionUseCase startFocusSessionUseCase;
  final StopFocusSessionUseCase stopFocusSessionUseCase;
  final GetFocusSessionHistoryUseCase getFocusSessionHistoryUseCase;

  FocusViewModel({
    required this.startFocusSessionUseCase,
    required this.stopFocusSessionUseCase,
    required this.getFocusSessionHistoryUseCase,
  });

  bool _isRunning = false;
  int _secondsRemaining = 0;
  List<FocusSession> _history = [];

  bool get isRunning => _isRunning;
  int get secondsRemaining => _secondsRemaining;
  List<FocusSession> get history => _history;

  Future<void> startSession(int minutes) async {
    setLoading(true);
    clearError();
    final result = await startFocusSessionUseCase(minutes);
    result.fold(
      (failure) => setError(failure.toUserMessage()),
      (_) {
        _isRunning = true;
        _secondsRemaining = minutes * 60;
      },
    );
    setLoading(false);
  }

  Future<void> stopSession() async {
    setLoading(true);
    clearError();
    final result = await stopFocusSessionUseCase();
    result.fold(
      (failure) => setError(failure.toUserMessage()),
      (_) {
        _isRunning = false;
        _secondsRemaining = 0;
      },
    );
    setLoading(false);
  }

  Future<void> loadHistory() async {
    setLoading(true);
    clearError();
    final result = await getFocusSessionHistoryUseCase();
    result.fold(
      (failure) => setError(failure.toUserMessage()),
      (sessions) => _history = sessions,
    );
    setLoading(false);
  }
}
