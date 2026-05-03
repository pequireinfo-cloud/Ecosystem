import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';

abstract class BookingRemoteDataSource {
  Future<List<Map<String, dynamic>>> getUserBookings(String userId);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final Dio dio;

  BookingRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    final response = await dio.get(
      '${ApiConfig.baseUrl}/bookings/user/$userId',
      options: Options(headers: ApiConfig.headers),
    );

    if (response.statusCode == 200) {
      final List data = response.data;
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }
}
