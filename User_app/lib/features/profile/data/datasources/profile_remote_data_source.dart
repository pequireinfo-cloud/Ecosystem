import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../auth/data/models/auth_model.dart';

abstract class ProfileRemoteDataSource {
  Future<AuthModel> getProfile();
  Future<AuthModel> updateProfile(Map<String, dynamic> profileData);
  Future<void> updatePreferences(Map<String, dynamic> preferences);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthModel> getProfile() async {
    final response = await dio.get(
      '${ApiConfig.baseUrl}/users/profile',
      options: Options(headers: ApiConfig.headers),
    );

    if (response.statusCode == 200) {
      return AuthModel.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }

  @override
  Future<AuthModel> updateProfile(Map<String, dynamic> profileData) async {
    final response = await dio.put(
      '${ApiConfig.baseUrl}/users/profile',
      options: Options(headers: ApiConfig.headers),
      data: profileData,
    );

    if (response.statusCode == 200) {
      return AuthModel.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }

  @override
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    await dio.put(
      '${ApiConfig.baseUrl}/users/preferences',
      options: Options(headers: ApiConfig.headers),
      data: preferences,
    );
  }
}
