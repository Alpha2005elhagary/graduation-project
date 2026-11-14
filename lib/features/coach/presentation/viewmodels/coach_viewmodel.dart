import 'package:breakbot/core/utils/failure.dart';
import 'package:breakbot/features/coach/domain/entities/coach_message.dart';
import 'package:breakbot/features/coach/domain/usecases/coach_usecases.dart';
import 'package:breakbot/shared/models/base_viewmodel.dart';

class CoachViewModel extends BaseViewModel {
  final SendCoachMessageUseCase sendCoachMessageUseCase;
  final GetMoodCravingUseCase getMoodCravingUseCase;
  final GetRelapseRiskUseCase getRelapseRiskUseCase;

  CoachViewModel({
    required this.sendCoachMessageUseCase,
    required this.getMoodCravingUseCase,
    required this.getRelapseRiskUseCase,
  });

  final List<CoachMessage> _messages = [];
  List<CoachMessage> get messages => _messages;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _messages.add(CoachMessage(text: text, isUser: true, timestamp: DateTime.now()));

    setLoading(true);
    clearError();
    final result = await sendCoachMessageUseCase(text);
    result.fold(
      (failure) => setError(failure.toUserMessage()),
      (response) {
        _messages.add(CoachMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      },
    );
    setLoading(false);
  }

  Future<Map<String, dynamic>?> getMoodCraving() async {
    setLoading(true);
    clearError();
    Map<String, dynamic>? result;
    final res = await getMoodCravingUseCase();
    res.fold(
      (failure) => setError(failure.toUserMessage()),
      (data) => result = data,
    );
    setLoading(false);
    return result;
  }

  Future<double?> getRelapseRisk() async {
    setLoading(true);
    clearError();
    double? risk;
    final res = await getRelapseRiskUseCase();
    res.fold(
      (failure) => setError(failure.toUserMessage()),
      (data) => risk = data,
    );
    setLoading(false);
    return risk;
  }
}
