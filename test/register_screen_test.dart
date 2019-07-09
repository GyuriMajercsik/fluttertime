import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_time/main.dart';
import 'package:flutter_time/src/blocs/authentication/authentication_bloc.dart';
import 'package:flutter_time/src/blocs/authentication/bloc.dart';
import 'package:flutter_time/src/blocs/register/register_bloc.dart';
import 'package:flutter_time/src/blocs/register/register_keys.dart';
import 'package:flutter_time/src/blocs/register/register_screen.dart';
import 'package:flutter_time/src/user_repository.dart';
import 'package:logging/logging.dart';
import 'package:mockito/mockito.dart';

import 'bloc_test_delegate.dart';
import 'mocks.dart';

void main() {
  AuthenticationBloc authenticationBloc;
  RegisterBloc registerBloc;
  MockUserRepository userRepository;

  setUp(() async {
    Logger.root.level = Level.FINEST;

    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    });
  });

  testWidgets('Registration screen', (WidgetTester tester) async {
    BlocSupervisor.delegate = LoggingBlocTestDelegate();

    userRepository = MockUserRepository();
    authenticationBloc = AuthenticationBloc(userRepository: userRepository);
    registerBloc = RegisterBloc(userRepository: userRepository);

    getIt.registerSingleton<AuthenticationBloc>(authenticationBloc);
    getIt.registerSingleton<UserRepository>(userRepository);
    getIt.registerSingleton<RegisterBloc>(registerBloc);

    var registerScreen = RegisterScreen();

    await tester.pumpWidget(MaterialApp(home: registerScreen));

    expect(find.byKey(registerEmailKey), findsOneWidget);
    expect(find.byKey(registerPasswordKey), findsOneWidget);

    expect(find.byKey(registerSubmitButtonKey), findsOneWidget);
    await tester.enterText(find.byKey(registerEmailKey), 'lorem@ipsum.com');
    await tester.enterText(find.byKey(registerPasswordKey), 'password7');

    await tester.pumpAndSettle();

    expect(
        tester
            .widget<RaisedButton>(find.byKey(registerSubmitButtonKey))
            .enabled,
        true);

    await tester.pumpAndSettle();

    when(userRepository.getUser())
        .thenAnswer((_) => Future.value('lorem@ipsum.com'));

    final expectedResponse = [
      Uninitialized(),
      Authenticated('lorem@ipsum.com'),
    ];
    expectLater(
      authenticationBloc.state,
      emitsInOrder(expectedResponse),
    );

    await tester.tap(find.byKey(registerSubmitButtonKey));
    await tester.pumpAndSettle();
  });
}
