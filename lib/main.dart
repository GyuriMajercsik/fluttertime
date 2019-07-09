import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_time/src/bloc_delegate.dart';
import 'package:flutter_time/src/blocs/authentication/bloc.dart';
import 'package:flutter_time/src/blocs/image_analyzer/image_analyzer_bloc.dart';
import 'package:flutter_time/src/blocs/login/bloc.dart';
import 'package:flutter_time/src/blocs/login/login_screen.dart';
import 'package:flutter_time/src/blocs/mqtt/mqtt_bloc.dart';
import 'package:flutter_time/src/blocs/product/products_bloc.dart';
import 'package:flutter_time/src/blocs/product/products_screen.dart';
import 'package:flutter_time/src/blocs/register/bloc.dart';
import 'package:flutter_time/src/blocs/shared_preferences/bloc.dart';
import 'package:flutter_time/src/blocs/speedometer/bloc.dart';
import 'package:flutter_time/src/firebase_crashlytics.dart';
import 'package:flutter_time/src/firebase_notifications.dart';
import 'package:flutter_time/src/firebase_remote_config.dart';
import 'package:flutter_time/src/local_notifications.dart';
import 'package:flutter_time/src/products_repository.dart';
import 'package:flutter_time/src/shared_preferences_repository.dart';
import 'package:flutter_time/src/splash_screen.dart';
import 'package:flutter_time/src/user_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

GetIt getIt = GetIt();

main() {
  BlocSupervisor.delegate = LoggingBlocDelegate();

  installCrashlytics();
  Logger.root.level = Level.FINE;

  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  runApp(App());
}

class App extends StatefulWidget {
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  ProductsRepository _productsRepository;
  SharedPreferencesRepository _sharedPreferencesRepository;
  FirebaseRemoteConfigRepository _firebaseRemoteConfigRepository;

  SharedPreferencesBloc _sharedPreferencesBloc;

  AuthenticationBloc get _authenticationBloc => getIt<AuthenticationBloc>();
  UserRepository get _userRepository => getIt<UserRepository>();

  @override
  void initState() {
    super.initState();

    getIt.registerLazySingleton<UserRepository>(() {
      return UserRepository();
    });

    getIt.registerLazySingleton<SpeedometerBloc>(() {
      return SpeedometerBloc();
    });

    getIt.registerLazySingleton<ImageAnalyzerBloc>(() {
      return ImageAnalyzerBloc();
    });

    getIt.registerLazySingleton<AuthenticationBloc>(() {
      return AuthenticationBloc(userRepository: _userRepository);
    });

    getIt.registerLazySingleton<ProductsBloc>(() {
      return ProductsBloc(productsRepository: _productsRepository);
    });

    getIt.registerLazySingleton<LocalNotifications>(() {
      var localNotifications = LocalNotifications();
      localNotifications.initialize();
      return localNotifications;
    });

    getIt.registerLazySingleton<FirebaseCloudMessaging>(() {
      var firebaseCloudMessaging = FirebaseCloudMessaging();
      firebaseCloudMessaging.initialize();
      return firebaseCloudMessaging;
    });

    getIt.registerLazySingleton<LoginBloc>(() {
      return LoginBloc(
        userRepository: _userRepository,
      );
    });

    getIt.registerLazySingleton<RegisterBloc>(() {
      return RegisterBloc(
        userRepository: _userRepository,
      );
    });

    getIt.registerLazySingleton<MqttBloc>(() {
      return MqttBloc();
    });

    _initAsync();
  }

  /// Initializing asynchronously because SharedPreferences.getInstance() is already async
  void _initAsync() async {
    _productsRepository = ProductsRepository(Firestore.instance);
    var sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferencesRepository =
        SharedPreferencesRepository(sharedPreferences);
    _firebaseRemoteConfigRepository = FirebaseRemoteConfigRepository();

    _sharedPreferencesBloc =
        SharedPreferencesBloc(_sharedPreferencesRepository);

    await _firebaseRemoteConfigRepository.initialize();

    getIt.registerSingleton<ProductsRepository>(_productsRepository);
    getIt.registerSingleton<SharedPreferencesRepository>(
        _sharedPreferencesRepository);
    getIt.registerSingleton<FirebaseRemoteConfigRepository>(
        _firebaseRemoteConfigRepository);

    getIt.registerSingleton<SharedPreferencesBloc>(_sharedPreferencesBloc);

    _authenticationBloc.dispatch(AppStarted());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder(
        bloc: _authenticationBloc,
        builder: (BuildContext context, AuthenticationState state) {
          if (state is Uninitialized) {
            return SplashScreen();
          }
          if (state is Unauthenticated) {
            return LoginScreen();
          }
          if (state is Authenticated) {
            _sharedPreferencesBloc
                .dispatch(SaveLastEmailAddress(state.emailAddress));

            return ProductsScreen(owner: state.emailAddress);
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _authenticationBloc.dispose();
    _sharedPreferencesBloc.dispose();
    super.dispose();
  }
}
