import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';

abstract class BookingRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserBookings(String userId);
}
