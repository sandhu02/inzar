import 'package:flutter_test/flutter_test.dart';
import 'package:inzar/features/auth/bloc/auth_bloc.dart';
import 'package:inzar/features/auth/bloc/auth_event.dart';
import 'package:inzar/features/auth/bloc/auth_state.dart';

void main() {
  group('AuthBloc Tests', () {
    late AuthBloc authBloc;

    setUp(() {
      authBloc = AuthBloc();
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state has default user Ayesha Khan', () {
      expect(authBloc.state.status, AuthStatus.authenticated);
      expect(authBloc.state.user?.name, 'Ayesha Khan');
      expect(authBloc.state.user?.initials, 'AK');
      expect(authBloc.state.user?.reportCount, 12);
    });

    test('SignInSubmitted signs in user and updates profile', () async {
      authBloc.add(const SignInSubmitted(email: 'test@example.com', password: 'password123'));
      await Future.delayed(const Duration(milliseconds: 650));

      expect(authBloc.state.status, AuthStatus.authenticated);
      expect(authBloc.state.user?.email, 'test@example.com');
      expect(authBloc.state.user?.signInMethod, 'Email');
    });

    test('SignOutRequested resets user to unauthenticated', () async {
      authBloc.add(const SignOutRequested());
      await pumpEventQueue();

      expect(authBloc.state.status, AuthStatus.unauthenticated);
      expect(authBloc.state.user, isNull);
    });

    test('DeleteAccountRequested removes user account', () async {
      authBloc.add(const DeleteAccountRequested());
      await pumpEventQueue();

      expect(authBloc.state.status, AuthStatus.unauthenticated);
      expect(authBloc.state.user, isNull);
    });
  });
}
