import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:drowsiness_guide/services/auth_service.dart';
import 'package:drowsiness_guide/services/user_role_service.dart';
import 'package:drowsiness_guide/services/ble_service.dart';
import 'package:drowsiness_guide/services/jetson_websocket_service.dart';
import 'package:drowsiness_guide/services/osm_places_service.dart';

// ---------------------------------------------------------------------------
// Lightweight Firebase fakes — used as default returnValues in mocks.
// ---------------------------------------------------------------------------

class FakeUser extends Fake implements User {
  @override
  String get uid => 'test-uid-123';
}

class FakeUserCredential extends Fake implements UserCredential {
  @override
  User? get user => FakeUser();
}

// ---------------------------------------------------------------------------
// AuthService mock
// Every non-void method needs an explicit noSuchMethod override with a valid
// returnValue so null-safe Dart doesn't throw during `when()` recording.
// ---------------------------------------------------------------------------

class MockAuthService extends Mock implements AuthService {
  @override
  User? get currentUser => super.noSuchMethod(
        Invocation.getter(#currentUser),
        returnValue: null,
        returnValueForMissingStub: null,
      );

  @override
  Stream<User?> get authStateChanges => super.noSuchMethod(
        Invocation.getter(#authStateChanges),
        returnValue: Stream<User?>.empty(),
        returnValueForMissingStub: Stream<User?>.empty(),
      ) as Stream<User?>;

  @override
  Future<UserCredential?> signInWithGoogle() => super.noSuchMethod(
        Invocation.method(#signInWithGoogle, const []),
        returnValue: Future<UserCredential?>.value(null),
        returnValueForMissingStub: Future<UserCredential?>.value(null),
      ) as Future<UserCredential?>;

  @override
  Future<UserCredential> signInWithEmailPassword(
          {required String email, required String password}) =>
      super.noSuchMethod(
        Invocation.method(#signInWithEmailPassword, const [],
            {#email: email, #password: password}),
        returnValue: Future.value(FakeUserCredential()),
        returnValueForMissingStub: Future.value(FakeUserCredential()),
      ) as Future<UserCredential>;

  @override
  Future<UserCredential> createUserWithEmailPassword(
          {required String email, required String password}) =>
      super.noSuchMethod(
        Invocation.method(#createUserWithEmailPassword, const [],
            {#email: email, #password: password}),
        returnValue: Future.value(FakeUserCredential()),
        returnValueForMissingStub: Future.value(FakeUserCredential()),
      ) as Future<UserCredential>;

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

  @override
  Future<UserProfile> saveRole({
    required String uid,
    required String role,
    String? email,
    String? displayName,
    String? fleetInviteCode,
    String? deviceId,
  }) =>
      super.noSuchMethod(
        Invocation.method(#saveRole, const [], {
          #uid: uid,
          #role: role,
          #email: email,
          #displayName: displayName,
          #fleetInviteCode: fleetInviteCode,
          #deviceId: deviceId,
        }),
        returnValue: Future.value(
          UserProfile(uid: uid, role: role, email: email, displayName: displayName),
        ),
        returnValueForMissingStub: Future.value(
          UserProfile(uid: uid, role: role),
        ),
      ) as Future<UserProfile>;

  @override
  Future<FleetDashboardData> fetchFleetDashboard() => super.noSuchMethod(
        Invocation.method(#fetchFleetDashboard, const []),
        returnValue: Future.value(
          FleetDashboardData(
            fleet: FleetInfo(id: '', name: '', inviteCode: ''),
            drivers: const [],
          ),
        ),
        returnValueForMissingStub: Future.value(
          FleetDashboardData(
            fleet: FleetInfo(id: '', name: '', inviteCode: ''),
            drivers: const [],
          ),
        ),
      ) as Future<FleetDashboardData>;

  @override
  Future<List<FleetAlert>> fetchDriverAlerts(String driverUid) =>
      super.noSuchMethod(
        Invocation.method(#fetchDriverAlerts, [driverUid]),
        returnValue: Future<List<FleetAlert>>.value(const []),
        returnValueForMissingStub: Future<List<FleetAlert>>.value(const []),
      ) as Future<List<FleetAlert>>;

  @override
  Future<void> removeDriver(String driverUid) => super.noSuchMethod(
        Invocation.method(#removeDriver, [driverUid]),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as Future<void>;
}

// ---------------------------------------------------------------------------
// BleService mock
// Streams are backed by public StreamControllers so tests can push events
// directly. Methods go through noSuchMethod so verify() works on them.
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
// JetsonWebSocketService mock — same pattern as BleService.
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

// ---------------------------------------------------------------------------
// OSMPlacesService mock
// ---------------------------------------------------------------------------

class MockOSMPlacesService extends Mock implements OSMPlacesService {
  @override
  Future<List<PlaceSummary>> fetchNearestGasStations({
    required double lat,
    required double lon,
    int limit = 5,
    int radiusMeters = 5000,
  }) =>
      super.noSuchMethod(
        Invocation.method(#fetchNearestGasStations, const [], {
          #lat: lat,
          #lon: lon,
          #limit: limit,
          #radiusMeters: radiusMeters,
        }),
        returnValue: Future<List<PlaceSummary>>.value(const []),
        returnValueForMissingStub: Future<List<PlaceSummary>>.value(const []),
      ) as Future<List<PlaceSummary>>;

  @override
  Future<List<PlaceSummary>> fetchRestStopsWithin30Miles({
    required double lat,
    required double lon,
  }) =>
      super.noSuchMethod(
        Invocation.method(#fetchRestStopsWithin30Miles, const [], {
          #lat: lat,
          #lon: lon,
        }),
        returnValue: Future<List<PlaceSummary>>.value(const []),
        returnValueForMissingStub: Future<List<PlaceSummary>>.value(const []),
      ) as Future<List<PlaceSummary>>;
}
