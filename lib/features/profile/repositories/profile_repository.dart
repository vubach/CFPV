import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

class ProfileRepository {
  final DioClient _dio;

  ProfileRepository({required DioClient dioClient}) : _dio = dioClient;

  Future<String?> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    });

    final response = await _dio.post(
      ApiConstants.uploadsAvatar,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    final data = response.data as Map<String, dynamic>;
    return data['avatarUrl'] as String?;
  }
}
