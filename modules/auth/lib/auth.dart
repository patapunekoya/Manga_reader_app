// modules/auth/lib/auth.dart

export 'domain/entities/user_entity.dart';
export 'presentation/bloc/auth_status/auth_status_bloc.dart';
export 'presentation/pages/login_page.dart';

// Init function để gọi ở bootstrap.dart
import 'package:get_it/get_it.dart';
import 'domain/repositories/auth_repository.dart';
import 'infrastructure/datasources/auth_remote_ds.dart';
import 'infrastructure/repositories/auth_repository_impl.dart';
import 'application/sign_in_with_email.dart';
import 'application/sign_up_with_email.dart';
import 'application/sign_out.dart';
import 'application/stream_auth_status.dart';
import 'presentation/bloc/auth_status/auth_status_bloc.dart';
import 'presentation/bloc/login_form/login_form_bloc.dart'; 

void initAuthModule(GetIt sl) {
  // Datasource
  sl.registerLazySingleton(() => AuthRemoteDataSource());

  // Repository
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()));

  // UseCases
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => StreamAuthStatus(sl()));

  // =======================================================
  // ĐĂNG KÝ AUTH STATUS BLOC (GLOBAL SINGLETON)
  // Fix lỗi GoRouter: Phải là Singleton/LazySingleton
  // =======================================================
  if (!sl.isRegistered<AuthStatusBloc>()) {
      sl.registerLazySingleton(() => AuthStatusBloc(
          streamAuthStatus: sl(),
          signOut: sl(),
      ));
  }
  
  // Đăng ký BLoC Form (LoginFormBloc) là Factory
  if (!sl.isRegistered<LoginFormBloc>()) {
      sl.registerFactory(() => LoginFormBloc(
          signIn: sl(),
          signUp: sl(),
      ));
  }
}