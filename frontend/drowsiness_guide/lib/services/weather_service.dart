import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  WeatherService({required this.apiKey});

  final String apiKey;

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

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('OpenWeather error ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final weather0 = (data['weather'] as List).isNotEmpty ? data['weather'][0] : {};
    final main = data['main'] as Map<String, dynamic>;

    return WeatherResult(
      condition: (weather0['main'] ?? 'Unknown') as String, 
      temperature: (main['temp'] as num).toDouble(),
    );
  }
}

class WeatherResult {
  final String condition;
  final double temperature;

  const WeatherResult({required this.condition, required this.temperature});
}
