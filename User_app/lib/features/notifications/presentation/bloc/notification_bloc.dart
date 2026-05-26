import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../injection_container.dart';

abstract class NotificationEvent {}

class FetchNotifications extends NotificationEvent {}

class MarkNotificationAsRead extends NotificationEvent {
  final String id;
  MarkNotificationAsRead(this.id);
}

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<dynamic> notifications;
  NotificationLoaded(this.notifications);
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final Dio _dio = sl<Dio>();

  NotificationBloc() : super(NotificationInitial()) {
    on<FetchNotifications>(_onFetchNotifications);
    on<MarkNotificationAsRead>(_onMarkAsRead);
  }

  Future<void> _onFetchNotifications(
      FetchNotifications event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      final prefs = sl<SharedPreferences>();
      final token = prefs.getString('auth_token');
      if (token == null) {
        emit(NotificationError('Unauthenticated'));
        return;
      }

      final response = await _dio.get(
        '/notifications',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        emit(NotificationLoaded(response.data['data'] ?? []));
      } else {
        emit(NotificationError('Failed to fetch notifications'));
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
      MarkNotificationAsRead event, Emitter<NotificationState> emit) async {
    try {
      final prefs = sl<SharedPreferences>();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      await _dio.put(
        '/notifications/${event.id}/read',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      // We could fetch notifications again or just update state optimistically, 
      // but for now, re-fetching is safest to ensure consistency.
      add(FetchNotifications());
    } catch (e) {
      print('Failed to mark read: $e');
    }
  }
}
