import 'dart:async';

import 'package:flutter/material.dart';
import 'package:drowsiness_guide/app.dart';
import 'package:drowsiness_guide/services/jetson_websocket_service.dart';
import 'package:drowsiness_guide/services/auth_service.dart';

class FleetOperatorDashboard extends StatefulWidget {
  const FleetOperatorDashboard({super.key});

  @override
  State<FleetOperatorDashboard> createState() => _FleetOperatorDashboardState();
}

class _FleetOperatorDashboardState extends State<FleetOperatorDashboard> {
  static const String _jetsonWsUrl = String.fromEnvironment(
    'JETSON_WS_URL',
    defaultValue: 'ws://localhost:8080/ws/alerts?replay=0',
  );

  late final JetsonWebSocketService _jetsonWs = JetsonWebSocketService(
    uri: Uri.parse(_jetsonWsUrl),
  );

  StreamSubscription<JetsonAlert>? _alertSub;
  StreamSubscription<JetsonPresence>? _presenceSub;
  StreamSubscription<String>? _stateSub;

  String _wsState = 'Disconnected';

  final Map<String, _DriverData> _driversByDeviceId = {
    'jetson_1': _DriverData(
      deviceId: 'jetson_1',
      name: 'Alex Chen',
      vehicle: 'Truck 12',
      risk: 22,
      status: 'Normal',
      isOnline: true,
      lastAlert: 'No recent alerts',
    ),
    'jetson_2': _DriverData(
      deviceId: 'jetson_2',
      name: 'Maria Lopez',
      vehicle: 'Van 4',
      risk: 55,
      status: 'Elevated',
      isOnline: true,
      lastAlert: 'Extended blink duration',
    ),
    'jetson_3': _DriverData(
      deviceId: 'jetson_3',
      name: 'James Park',
      vehicle: 'Truck 7',
      risk: 82,
      status: 'Critical',
      isOnline: true,
      lastAlert: 'Eyes closed too long',
    ),
    'jetson_4': _DriverData(
      deviceId: 'jetson_4',
      name: 'Ethan Wong',
      vehicle: 'Car 2',
      risk: 10,
      status: 'Normal',
      isOnline: false,
      lastAlert: 'No recent alerts',
    ),
  };

  @override
  void initState() {
    super.initState();

    _stateSub = _jetsonWs.connectionState.listen((state) {
      if (!mounted) return;
      setState(() {
        _wsState = state;
      });
    });

    _alertSub = _jetsonWs.alerts.listen(_handleAlert);
    _presenceSub = _jetsonWs.presence.listen(_handlePresence);

    _jetsonWs.connect();
  }

  @override
  void dispose() {
    _alertSub?.cancel();
    _presenceSub?.cancel();
    _stateSub?.cancel();
    _jetsonWs.dispose();
    super.dispose();
  }

  void _handleAlert(JetsonAlert alert) {
    if (!mounted) return;

    setState(() {
      final existing = _driversByDeviceId[alert.deviceId];

      final updatedRisk = _riskFromLevel(alert.level);
      final updatedStatus = _statusFromRisk(updatedRisk);

      if (existing != null) {
        _driversByDeviceId[alert.deviceId] = existing.copyWith(
          risk: updatedRisk,
          status: updatedStatus,
          isOnline: true,
          lastAlert: alert.message,
          lastUpdated: alert.timestamp,
        );
      } else {
        _driversByDeviceId[alert.deviceId] = _DriverData(
          deviceId: alert.deviceId,
          name: alert.deviceId,
          vehicle: 'Unassigned Vehicle',
          risk: updatedRisk,
          status: updatedStatus,
          isOnline: true,
          lastAlert: alert.message,
          lastUpdated: alert.timestamp,
        );
      }
    });
  }

  void _handlePresence(JetsonPresence presence) {
    if (!mounted) return;

    setState(() {
      final existing = _driversByDeviceId[presence.sourceId];

      if (existing != null) {
        _driversByDeviceId[presence.sourceId] = existing.copyWith(
          isOnline: presence.online,
          lastUpdated: presence.timestamp,
        );
      } else {
        _driversByDeviceId[presence.sourceId] = _DriverData(
          deviceId: presence.sourceId,
          name: presence.sourceId,
          vehicle: 'Unassigned Vehicle',
          risk: 0,
          status: 'Normal',
          isOnline: presence.online,
          lastAlert: 'No recent alerts',
          lastUpdated: presence.timestamp,
        );
      }
    });
  }

  int _riskFromLevel(int level) {
    switch (level) {
      case 0:
        return 20;
      case 1:
        return 55;
      case 2:
        return 85;
      default:
        return 30;
    }
  }

  String _statusFromRisk(int risk) {
    if (risk >= 70) return 'Critical';
    if (risk >= 40) return 'Elevated';
    return 'Normal';
  }

  List<_DriverData> get _sortedDrivers {
    final list = _driversByDeviceId.values.toList()
      ..sort((a, b) => b.risk.compareTo(a.risk));
    return list;
  }

  Future<void> _backToLogin() async {
    await AuthService().signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DriverSafetyApp.of(context).isDark;
    final bgTop = isDark ? const Color(0xFF0B1220) : const Color(0xFFCED8E4);
    final bgBottom = isDark ? const Color(0xFF0E1628) : const Color(0xFF7E97B9);

    final sortedDrivers = _sortedDrivers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fleet Dashboard'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: _ConnectionBadge(state: _wsState),
            ),
          ),
          IconButton(
            onPressed: _backToLogin,
            tooltip: 'Back to login',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgTop, bgBottom],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _SummaryRow(drivers: sortedDrivers),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: sortedDrivers.length,
                  itemBuilder: (context, i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _DriverCard(
                        driver: sortedDrivers[i],
                        rank: i + 1,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DriverData {
  final String deviceId;
  final String name;
  final String vehicle;
  final int risk;
  final String status;
  final bool isOnline;
  final String lastAlert;
  final DateTime? lastUpdated;

  const _DriverData({
    required this.deviceId,
    required this.name,
    required this.vehicle,
    required this.risk,
    required this.status,
    required this.isOnline,
    required this.lastAlert,
    this.lastUpdated,
  });

  _DriverData copyWith({
    String? deviceId,
    String? name,
    String? vehicle,
    int? risk,
    String? status,
    bool? isOnline,
    String? lastAlert,
    DateTime? lastUpdated,
  }) {
    return _DriverData(
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      vehicle: vehicle ?? this.vehicle,
      risk: risk ?? this.risk,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      lastAlert: lastAlert ?? this.lastAlert,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
    }
}

Color _riskColor(int risk) {
  if (risk >= 70) return const Color(0xFFEF4444);
  if (risk >= 40) return const Color(0xFFF59E0B);
  return const Color(0xFF10B981);
}

class _DriverCard extends StatelessWidget {
  final _DriverData driver;
  final int rank;

  const _DriverCard({
    required this.driver,
    required this.rank,
  });

  String _formatTime(DateTime? time) {
    if (time == null) return 'No data yet';
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final color = _riskColor(driver.risk);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: driver.risk / 100,
                    strokeWidth: 6,
                    color: color,
                    backgroundColor: Colors.grey.shade300,
                  ),
                  Center(
                    child: Text(
                      '${driver.risk}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#$rank • ${driver.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(driver.vehicle),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _StatusBadge(
                        label: driver.status,
                        color: color,
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(
                        label: driver.isOnline ? 'Live' : 'Offline',
                        color: driver.isOnline
                            ? const Color(0xFF10B981)
                            : Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    driver.lastAlert,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last updated: ${_formatTime(driver.lastUpdated)}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final List<_DriverData> drivers;

  const _SummaryRow({required this.drivers});

  @override
  Widget build(BuildContext context) {
    final total = drivers.length;
    final critical = drivers.where((d) => d.risk >= 70).length;
    final elevated = drivers.where((d) => d.risk >= 40 && d.risk < 70).length;
    final offline = drivers.where((d) => !d.isOnline).length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _SummaryBox('Drivers', total.toString()),
        _SummaryBox('Critical', critical.toString()),
        _SummaryBox('Elevated', elevated.toString()),
        _SummaryBox('Offline', offline.toString()),
      ],
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryBox(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionBadge extends StatelessWidget {
  final String state;

  const _ConnectionBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    final isConnected = state == 'Connected';
    final color = isConnected ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        state,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}