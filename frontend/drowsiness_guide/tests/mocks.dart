import 'dart:async';
import 'package:mockito/mockito.dart';
import 'package:drowsiness_guide/services/auth_service.dart';
import 'package:drowsiness_guide/services/user_role_service.dart';
import 'package:drowsiness_guide/services/ble_service.dart';
import 'package:drowsiness_guide/services/jetson_websocket_service.dart';

// ---------------------------------------------------------------------------
// Fake AuthUser — used as returnValue in MockAuthService.
// ---------------------------------------------------------------------------

class FakeAuthUser extends AuthUser {
  const FakeAuthUser() : super(uid: 'test-uid-123', email: 'user@example.com');
}

// ---------------------------------------------------------------------------
// AuthService mock
// ---------------------------------------------------------------------------

class MockAuthService extends Mock implements AuthService {
  @override
  AuthUser? get currentUser => super.noSuchMethod(
        Invocation.getter(#currentUser),
        returnValue: null,
        returnValueForMissingStub: null,
      );

  @override
  Stream<AuthUser?> get authStateChanges => super.noSuchMethod(
        Invocation.getter(#authStateChanges),
        returnValue: Stream<AuthUser?>.empty(),
        returnValueForMissingStub: Stream<AuthUser?>.empty(),
      ) as Stream<AuthUser?>;

  @override
  Future<AuthUser> signInWithEmailPassword(
          {required String email, required String password}) =>
      super.noSuchMethod(
        Invocation.method(#signInWithEmailPassword, const [],
            {#email: email, #password: password}),
        returnValue: Future.value(const FakeAuthUser()),
        returnValueForMissingStub: Future.value(const FakeAuthUser()),
      ) as Future<AuthUser>;

  @override
  Future<AuthUser> createUserWithEmailPassword(
          {required String email, required String password}) =>
      super.noSuchMethod(
        Invocation.method(#createUserWithEmailPassword, const [],
            {#email: email, #password: password}),
        returnValue: Future.value(const FakeAuthUser()),
        returnValueForMissingStub: Future.value(const FakeAuthUser()),
      ) as Future<AuthUser>;

  @override
  Future<void> signOut() => super.noSuchMethod(
        Invocation.method(#signOut, const []),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as Future<void>;
}

// ---------------------------------------------------------------------------
// UserRoleService mock
// ---------------------------------------------------------------------------

class MockUserRoleService extends Mock implements UserRoleService {
  @override
  Future<String?> fetchRole(String uid) => super.noSuchMethod(
        Invocation.method(#fetchRole, [uid]),
        returnValue: Future<String?>.value(null),
        returnValueForMissingStub: Future<String?>.value(null),
      ) as Future<String?>;

  @override
  Future<UserProfile?> fetchProfile(String uid) => super.noSuchMethod(
        Invocation.method(#fetchProfile, [uid]),
        returnValue: Future<UserProfile?>.value(null),
        returnValueForMissingStub: Future<UserProfile?>.value(null),
      ) as Future<UserProfile?>;
}

// ---------------------------------------------------------------------------
// BleService mock
// ---------------------------------------------------------------------------

class MockBleService extends Mock implements BleService {
  final alertCtrl = StreamController<BleAlert>.broadcast();
  final stateCtrl = StreamController<String>.broadcast();

  @override
  Stream<BleAlert> get alerts => alertCtrl.stream;

  @override
  Stream<String> get connectionState => stateCtrl.stream;

  @override
  Future<void> scanAndConnect({bool userInitiated = false}) =>
      super.noSuchMethod(
        Invocation.method(#scanAndConnect, const [],
            {#userInitiated: userInitiated}),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<void> disconnect() => super.noSuchMethod(
        Invocation.method(#disconnect, const []),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as Future<void>;

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(#dispose, const []),
        returnValue: null,
        returnValueForMissingStub: null,
      );
}

// ---------------------------------------------------------------------------
// JetsonWebSocketService mock
// ---------------------------------------------------------------------------

class MockJetsonWebSocketService extends Mock
    implements JetsonWebSocketService {
  final alertCtrl = StreamController<JetsonAlert>.broadcast();
  final presenceCtrl = StreamController<JetsonPresence>.broadcast();
  final stateCtrl = StreamController<String>.broadcast();

  @override
  Stream<JetsonAlert> get alerts => alertCtrl.stream;

  @override
  Stream<JetsonPresence> get presence => presenceCtrl.stream;

  @override
  Stream<String> get connectionState => stateCtrl.stream;

  @override
  Future<void> connect() => super.noSuchMethod(
        Invocation.method(#connect, const []),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<void> disconnect() => super.noSuchMethod(
        Invocation.method(#disconnect, const []),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as Future<void>;

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(#dispose, const []),
        returnValue: null,
        returnValueForMissingStub: null,
      );
}
