import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../datasources/booking_remote_data_source.dart';
import '../../domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserBookings(String userId) async {
    try {
      final bookings = await remoteDataSource.getUserBookings(userId);
      return Right(bookings);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Failed to fetch bookings'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
