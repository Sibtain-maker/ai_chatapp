import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppState {
  final bool isLoading;
  final String? error;
  final bool isFirstLaunch;

  const AppState({
    this.isLoading = false,
    this.error,
    this.isFirstLaunch = true,
  });

  AppState copyWith({
    bool? isLoading,
    String? error,
    bool? isFirstLaunch,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState());

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void setFirstLaunch(bool isFirst) {
    state = state.copyWith(isFirstLaunch: isFirst);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});