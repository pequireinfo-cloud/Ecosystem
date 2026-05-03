import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class GetProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final Map<String, dynamic> profileData;
  const UpdateProfile(this.profileData);

  @override
  List<Object?> get props => [profileData];
}

class UpdatePreferences extends ProfileEvent {
  final Map<String, dynamic> preferences;
  const UpdatePreferences(this.preferences);

  @override
  List<Object?> get props => [preferences];
}
