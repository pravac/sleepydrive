import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../secrets.dart';
import '../services/places_service.dart';

Color _white(double opacity) => Colors.white.withAlpha((opacity * 255).round());

class DrowsinessDetectedScreen extends StatefulWidget {
  const DrowsinessDetectedScreen({super.key});

  @override
  State<DrowsinessDetectedScreen> createState() => _DrowsinessDetectedScreenState();
}

class _DrowsinessDetectedScreenState extends State<DrowsinessDetectedScreen> {
  static const double _restStopMaxMeters = 30.0 * 1609.344; // 30 miles

  bool _loading = false;
  String? _err;
  Position? _pos;
  List<_GasStationCardModel> _stations = const [];
  List<_RestStopCardModel> _restStops = const [];

  @override
  void initState() {
    super.initState();
    _loadNearestGasStations();
  }

  Future<void> _loadNearestGasStations() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _err = null;
      _stations = const [];
      _restStops = const [];
    });

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );

      final svc = PlacesService(apiKey: googlePlacesApiKey);

      final gasPlaces = await svc.fetchNearestGasStations(
        lat: pos.latitude,
        lon: pos.longitude,
        limit: 5,
      );
      final stationModels = gasPlaces
          .map(
            (p) => _GasStationCardModel(
              name: p.name,
              vicinity: p.vicinity,
              lat: p.lat,
              lon: p.lon,
              distanceMeters: Geolocator.distanceBetween(
                pos.latitude,
                pos.longitude,
                p.lat,
                p.lon,
              ),
            ),
          )
          .toList(growable: false);

      final restPlaces = await svc.fetchNearestRestStops(
        lat: pos.latitude,
        lon: pos.longitude,
      );
      final restWithDistance = restPlaces.map((p) {
        final meters = Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          p.lat,
          p.lon,
        );
        return _RestStopCardModel(
          name: p.name,
          vicinity: p.vicinity,
          lat: p.lat,
          lon: p.lon,
          distanceMeters: meters,
        );
      }).toList();
      final restFiltered = restWithDistance
          .where((r) => r.distanceMeters <= _restStopMaxMeters)
          .toList(growable: false);

      if (!mounted) return;
      setState(() {
        _pos = pos;
        _stations = stationModels;
        _restStops = restFiltered;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _err = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openDirectionsTo(double lat, double lon) async {
    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '$lat,$lon',
      if (_pos != null) 'origin': '${_pos!.latitude},${_pos!.longitude}',
      'travelmode': 'driving',
    });

    final ok = await launchUrl(uri, mode: LaunchMode.platformDefault);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps directions.')),
      );
    }
  }

  String _formatMiles(double meters) {
    final miles = meters / 1609.344;
    if (miles < 0.1) return '${(miles * 5280).round()} ft';
    return '${miles.toStringAsFixed(miles < 10 ? 1 : 0)} mi';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DROWSINESS DETECTED',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 2.0),
        ),
        actions: [
          IconButton(
            onPressed: _loadNearestGasStations,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh nearby gas stations',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nearby gas stations (nearest 5)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _white(0.9),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
              Text(
                'Finding the nearest gas stations…',
                style: TextStyle(color: _white(0.7)),
              ),
            ] else if (_err != null) ...[
              Text(
                'Could not load gas stations.',
                style: TextStyle(fontWeight: FontWeight.w700, color: _white(0.9)),
              ),
              const SizedBox(height: 8),
              Text(
                _err!,
                style: TextStyle(color: _white(0.65)),
              ),
            ] else ...[
              if (_stations.isEmpty)
                Text(
                  'No results.',
                  style: TextStyle(color: _white(0.7)),
                )
              else ...[
              SizedBox(
                height: 170,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _stations.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, idx) {
                    final s = _stations[idx];
                    return SizedBox(
                      width: 280,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (s.vicinity.isNotEmpty)
                                Text(
                                  s.vicinity,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: _white(0.7)),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                _formatMiles(s.distanceMeters),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _white(0.8),
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: () => _openDirectionsTo(s.lat, s.lon),
                                  child: const Text('Directions'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tip: tap “Directions” to open Google Maps.',
                style: TextStyle(color: _white(0.6)),
              ),
              ],
            const SizedBox(height: 24),
            Text(
              'Nearby rest stops (within 30 miles)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _white(0.9),
              ),
            ),
            const SizedBox(height: 12),
            if (_restStops.isEmpty)
              Text(
                'No rest stops within 30 miles',
                style: TextStyle(color: _white(0.7)),
              )
            else
              SizedBox(
                height: 170,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _restStops.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, idx) {
                    final r = _restStops[idx];
                    return SizedBox(
                      width: 280,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (r.vicinity.isNotEmpty)
                                Text(
                                  r.vicinity,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: _white(0.7)),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                _formatMiles(r.distanceMeters),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _white(0.8),
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: () => _openDirectionsTo(r.lat, r.lon),
                                  child: const Text('Directions'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GasStationCardModel {
  final String name;
  final String vicinity;
  final double lat;
  final double lon;
  final double distanceMeters;

  const _GasStationCardModel({
    required this.name,
    required this.vicinity,
    required this.lat,
    required this.lon,
    required this.distanceMeters,
  });
}

class _RestStopCardModel {
  final String name;
  final String vicinity;
  final double lat;
  final double lon;
  final double distanceMeters;

  const _RestStopCardModel({
    required this.name,
    required this.vicinity,
    required this.lat,
    required this.lon,
    required this.distanceMeters,
  });
}
