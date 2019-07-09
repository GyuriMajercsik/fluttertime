import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_time/src/blocs/authentication/authentication_bloc.dart';
import 'package:flutter_time/src/blocs/authentication/bloc.dart';
import 'package:mockito/mockito.dart';

import 'mocks.dart';

void main() {
  AuthenticationBloc authenticationBloc;
  MockUserRepository userRepository;

  setUp(() {
    userRepository = MockUserRepository();
    authenticationBloc = AuthenticationBloc(userRepository: userRepository);
  });

  test('initial state is correct', () {
    expect(authenticationBloc.initialState, Uninitialized());
  });

  test('dispose does not emit new states', () {
    expectLater(
      authenticationBloc.state,
      emitsInOrder([]),
    );
    authenticationBloc.dispose();
  });

  group('AppStarted', () {
    test('emits [uninitialized, unauthenticated] for invalid email address',
        () {
      final expectedResponse = [Uninitialized(), Unauthenticated()];

      when(userRepository.getUser())
          .thenAnswer((_) => Future.value('lorem@ipsum.com'));

      expectLater(
        authenticationBloc.state,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.dispatch(AppStarted());
    });
  });

  group('LoggedIn', () {
    test('emits [uninitialized, authenticated] when email address is persisted',
        () {
      final expectedResponse = [
        Uninitialized(),
        Authenticated('lorem@ipsum.com'),
      ];
      when(userRepository.getUser())
          .thenAnswer((_) => Future.value('lorem@ipsum.com'));

      expectLater(
        authenticationBloc.state,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.dispatch(LoggedIn());
    });
  });

  group('LoggedOut', () {
    test('emits [uninitialized, unauthenticated] when email address is deleted',
        () {
      final expectedResponse = [
        Uninitialized(),
        Unauthenticated(),
      ];

      expectLater(
        authenticationBloc.state,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.dispatch(LoggedOut());
    });
  });
}
