import 'package:equatable/equatable.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class GetUserOrders extends OrderEvent {
  final String userId;
  const GetUserOrders(this.userId);

  @override
  List<Object?> get props => [userId];
}
