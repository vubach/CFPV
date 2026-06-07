import '../model/rewards_transaction_model.dart';

/// State of rewards operations.
sealed class RewardsState {
  const RewardsState();

  bool get isLoading => this is RewardsLoading;
  bool get hasError => this is RewardsError;
  List<RewardsTransaction> get transactions => switch (this) {
        RewardsLoaded(:final transactions) => transactions,
        _ => <RewardsTransaction>[],
      };
  int get balance => switch (this) {
        RewardsLoaded(:final balance) => balance,
        _ => 0,
      };
  String? get errorMessage => switch (this) {
        RewardsError(:final message) => message,
        _ => null,
      };
}

class RewardsInitial extends RewardsState {
  const RewardsInitial();
}

class RewardsLoading extends RewardsState {
  const RewardsLoading();
}

class RewardsLoaded extends RewardsState {
  @override
  final int balance;
  @override
  final List<RewardsTransaction> transactions;

  const RewardsLoaded({
    required this.balance,
    this.transactions = const [],
  });
}

class RewardsError extends RewardsState {
  final String message;

  const RewardsError(this.message);
}
