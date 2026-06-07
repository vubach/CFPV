import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../model/rewards_transaction_model.dart';
import '../repository/rewards_repository.dart';
import '../state/rewards_state.dart';

/// Manages rewards state: fetch balance and transactions.
class RewardsNotifier extends StateNotifier<RewardsState> {
  final RewardsRepository _repository;

  RewardsNotifier(this._repository) : super(const RewardsInitial());

  /// Fetch balance and transactions.
  Future<void> fetchRewards() async {
    state = const RewardsLoading();
    try {
      final results = await Future.wait([
        _repository.fetchBalance(),
        _repository.fetchTransactions(),
      ]);
      final balance = results[0] as int;
      final transactions = results[1] as List<RewardsTransaction>;
      state = RewardsLoaded(
        balance: balance,
        transactions: transactions,
      );
    } catch (e) {
      state = RewardsError(e.toString());
    }
  }
}

final rewardsProvider =
    StateNotifierProvider<RewardsNotifier, RewardsState>((ref) {
  final dio = DioClient.instance;
  final repository = RewardsRepository(dioClient: dio);
  return RewardsNotifier(repository);
});
