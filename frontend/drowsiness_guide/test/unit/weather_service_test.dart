import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:drowsiness_guide/services/weather_service.dart';

void main() {
  test('fetchCurrent parses OpenWeather-style JSON', () async {
    final client = MockClient((request) async {
      expect(request.url.host, 'api.openweathermap.org');
      return http.Response(
        jsonEncode({
          'name': 'Boston',
          'weather': [
            {'main': 'Clear'},
          ],
          'main': {'temp': 72.5},
        }),
        200,
      );
    });

    final svc = WeatherService(apiKey: 'test-key', httpClient: client);
    final r = await svc.fetchCurrent(lat: 42.0, lon: -71.0);

    expect(r.city, 'Boston');
    expect(r.condition, 'Clear');
    expect(r.temperature, 72.5);
  });

  test('fetchCurrent throws on non-200', () async {
    final client = MockClient(
      (request) async => http.Response('err', 500),
    );
    final svc = WeatherService(apiKey: 'k', httpClient: client);

    expect(
      () => svc.fetchCurrent(lat: 0, lon: 0),
      throwsException,
    );
  });
}
