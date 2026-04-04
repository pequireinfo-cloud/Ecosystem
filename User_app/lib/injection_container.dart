import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/register_usecase.dart';
import 'presentation/state/auth_bloc.dart';
import 'core/services/tracking_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Auth
  // Bloc
  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        registerUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  // External
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => TrackingService());
}
