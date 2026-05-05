import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/mockito.dart';
import 'package:drowsiness_guide/screens/drowsiness_detected_screen.dart';
import 'package:drowsiness_guide/services/osm_places_service.dart';
import '../helpers/mocks.dart';

const _lat = 37.78;
const _lon = -122.42;

Position _fakePosition() => Position(
      latitude: _lat,
      longitude: _lon,
      timestamp: DateTime.now(),
      accuracy: 10,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

void main() {
  late MockOSMPlacesService mockPlaces;

  setUp(() {
    mockPlaces = MockOSMPlacesService();
  });

  testWidgets('shows gas station name when places load', (tester) async {
    when(
      mockPlaces.fetchNearestGasStations(
        lat: _lat,
        lon: _lon,
        limit: 5,
        radiusMeters: 5000,
      ),
    ).thenAnswer(
      (_) async => const [
        PlaceSummary(
          name: 'Test Gas',
          vicinity: 'Main St',
          lat: _lat,
          lon: _lon,
        ),
      ],
    );
    when(
      mockPlaces.fetchRestStopsWithin30Miles(
        lat: _lat,
        lon: _lon,
      ),
    ).thenAnswer((_) async => []);

    await tester.pumpWidget(
      MaterialApp(
        home: DrowsinessDetectedScreen(
          placesService: mockPlaces,
          getCurrentPosition: () async => _fakePosition(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Test Gas'), findsWidgets);
  });

  testWidgets('shows error message when location fails', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DrowsinessDetectedScreen(
          placesService: mockPlaces,
          getCurrentPosition: () async => throw Exception('no gps'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.text('Location services error, check location permissions'),
      findsOneWidget,
    );
  });
}
