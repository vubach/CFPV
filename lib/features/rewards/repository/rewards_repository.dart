import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../model/rewards_transaction_model.dart';

/// Handles all rewards-related API calls.
class RewardsRepository {
  final DioClient _dio;

  RewardsRepository({required DioClient dioClient}) : _dio = dioClient;

  /// Fetch the current rewards balance.
  Future<int> fetchBalance() async {
    final response = await _dio.get(ApiConstants.rewardsBalance);
    return (response.data as Map<String, dynamic>)['balance'] as int;
  }

  /// Fetch the reward transaction history.
  Future<List<RewardsTransaction>> fetchTransactions() async {
    final response = await _dio.get(ApiConstants.rewardsTransactions);
    final data = response.data;
    if (data is List) {
      return data
          .map((e) =>
              RewardsTransaction.fromJson(e as Map<String, dynamic>),)
          .toList();
    }
    return [];
  }
}
