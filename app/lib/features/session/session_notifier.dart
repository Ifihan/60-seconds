import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/models/area_dto.dart';

class SessionState {
  final AreaDto? selectedArea;
  final String? currentTopic;
  final int prepTimeRemaining;
  final String prepNotes;

  const SessionState({
    this.selectedArea,
    this.currentTopic,
    this.prepTimeRemaining = 300,
    this.prepNotes = '',
  });

  SessionState copyWith({
    AreaDto? selectedArea,
    String? currentTopic,
    int? prepTimeRemaining,
    String? prepNotes,
  }) =>
      SessionState(
        selectedArea: selectedArea ?? this.selectedArea,
        currentTopic: currentTopic ?? this.currentTopic,
        prepTimeRemaining: prepTimeRemaining ?? this.prepTimeRemaining,
        prepNotes: prepNotes ?? this.prepNotes,
      );
}

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier() : super(const SessionState());

  void setSelectedArea(AreaDto area) => state = state.copyWith(selectedArea: area);
  void setCurrentTopic(String topic) => state = state.copyWith(currentTopic: topic);
  void setPrepTimeRemaining(int s) => state = state.copyWith(prepTimeRemaining: s);
  void setPrepNotes(String notes) => state = state.copyWith(prepNotes: notes);

  void resetSession() {
    state = const SessionState();
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>(
  (_) => SessionNotifier(),
);
