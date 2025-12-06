import 'package:shared_dependencies/shared_dependencies.dart';
import '../auth.dart';

final sl = GetIt.instance;

Future<void> initAuthDI() async {
  // Datasource
  if (!sl.isRegistered<AuthRemoteDataSource>()) {
    sl.registerLazySingleton(() => AuthRemoteDataSource());
  }
  // Repository
  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()));
  }
  // UseCases
  if (!sl.isRegistered<SignInWithEmail>()) {
    sl.registerLazySingleton(() => SignInWithEmail(sl()));
  }
  if (!sl.isRegistered<SignUpWithEmail>()) {
    sl.registerLazySingleton(() => SignUpWithEmail(sl()));
  }
  if (!sl.isRegistered<SignOut>()) {
    sl.registerLazySingleton(() => SignOut(sl()));
  }
  if (!sl.isRegistered<StreamAuthStatus>()) {
    sl.registerLazySingleton(() => StreamAuthStatus(sl()));
  }

  // GLOBAL BLOC: AuthStatusBloc (Singleton)
  if (!sl.isRegistered<AuthStatusBloc>()) {
    sl.registerLazySingleton(() => AuthStatusBloc(
          streamAuthStatus: sl(),
          signOut: sl(),
        ));
  }

  // FORM BLOC: LoginFormBloc (Factory)
  if (!sl.isRegistered<LoginFormBloc>()) {
    sl.registerFactory(() => LoginFormBloc(
          signIn: sl(),
          signUp: sl(),
        ));
  }
}