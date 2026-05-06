import 'package:flutter/material.dart';
import 'app.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  runApp(DriverSafetyApp(authService: authService));
}
