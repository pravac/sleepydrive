import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  WeatherService({required this.apiKey, http.Client? httpClient})
      : _client = httpClient ?? http.Client();

  final String apiKey;
  final http.Client _client;

  Future<WeatherResult> fetchCurrent({
    required double lat,
    required double lon,
    String units = 'imperial',
  }) async {
    final uri = Uri.https(
      'api.openweathermap.org',
      '/data/2.5/weather',
      {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'appid': apiKey,
        'units': units,
      },
    );

    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('OpenWeather error ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final weather0 = (data['weather'] as List).isNotEmpty ? data['weather'][0] : {};
    final main = data['main'] as Map<String, dynamic>;
    final city = (data['name'] as String?)?.trim();

    return WeatherResult(
      city: city == null || city.isEmpty ? null : city,
      condition: (weather0['main'] ?? 'Unknown') as String,
      temperature: (main['temp'] as num).toDouble(),
    );
  }
}

class WeatherResult {
  final String? city;
  final String condition;
  final double temperature;

  const WeatherResult({
    required this.city,
    required this.condition,
    required this.temperature,
  });
}
