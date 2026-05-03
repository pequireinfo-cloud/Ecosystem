import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pequire_user_app/core/error/failure.dart';
import '../../domain/repositories/booking_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final BookingRepository repository;

  OrderBloc({required this.repository}) : super(OrderInitial()) {
    on<GetUserOrders>(_onGetUserOrders);
  }

  Future<void> _onGetUserOrders(GetUserOrders event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    final result = await repository.getUserBookings(event.userId);
    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (orders) => emit(OrderLoaded(orders)),
    );
  }
}
