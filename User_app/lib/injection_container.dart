import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'core/services/tracking_service.dart';
import 'core/services/location_service.dart';
import 'core/locale/locale_cubit.dart';
import 'core/theme/theme_cubit.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Auth
  // Bloc
  sl.registerFactory(() => AuthBloc(
        repository: sl(),
      ));
  sl.registerFactory(() => LocaleCubit());
  sl.registerFactory(() => ThemeCubit());

  // Use cases (keeping for legacy if needed, but Bloc now uses repository directly)
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => TrackingService());
  sl.registerLazySingleton(() => LocationService());
}
