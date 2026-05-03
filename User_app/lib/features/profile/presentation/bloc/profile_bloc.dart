import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pequire_user_app/core/error/failure.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc({required this.repository}) : super(ProfileInitial()) {
    on<GetProfile>(_onGetProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UpdatePreferences>(_onUpdatePreferences);
  }

  Future<void> _onGetProfile(GetProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    final result = await repository.getProfile();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(ProfileLoaded(user)),
    );
  }

  Future<void> _onUpdateProfile(UpdateProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    final result = await repository.updateProfile(event.profileData);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(ProfileLoaded(user)),
    );
  }

  Future<void> _onUpdatePreferences(UpdatePreferences event, Emitter<ProfileState> emit) async {
    final result = await repository.updatePreferences(event.preferences);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => add(GetProfile()), // Refresh profile after preference update
    );
  }
}
