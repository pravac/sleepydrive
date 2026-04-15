import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:drowsiness_guide/app.dart';
import 'package:drowsiness_guide/services/auth_service.dart';

class RoleSelectionScreen extends StatefulWidget {
  final String email;
  final String password;

  const RoleSelectionScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final AuthService _authService = AuthService();

  static const String _backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  bool _isLoading = false;
  String? _errorText;

  Future<void> _saveUserRole({
    required String uid,
    required String role,
  }) async {
    final url = Uri.parse('$_backendBaseUrl/users');

    debugPrint('ROLE SAVE URL: $url');
    debugPrint('ROLE SAVE BODY: {"uid":"$uid","role":"$role"}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'uid': uid,
        'role': role,
      }),
    );

    debugPrint('ROLE SAVE STATUS: ${response.statusCode}');
    debugPrint('ROLE SAVE RESPONSE: ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to save user role (status ${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<void> _createAccountAndRoute({
    required String role,
    required String routeName,
  }) async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      debugPrint('START SIGNUP');
      debugPrint('EMAIL: ${widget.email}');
      debugPrint('ROLE: $role');
      debugPrint('BACKEND BASE URL: $_backendBaseUrl');

      await _authService.createUserWithEmailPassword(
        email: widget.email,
        password: widget.password,
      );

      debugPrint('FIREBASE ACCOUNT CREATED');

      final user = FirebaseAuth.instance.currentUser;
      debugPrint('CURRENT USER UID: ${user?.uid}');
      debugPrint('CURRENT USER EMAIL: ${user?.email}');

      if (user == null) {
        throw Exception('No authenticated user found after signup');
      }

      await _saveUserRole(uid: user.uid, role: role);

      debugPrint('ROLE SAVED TO BACKEND');
      debugPrint('ROUTING TO: $routeName');

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        routeName,
        (route) => false,
      );
    } catch (e, st) {
      debugPrint('ROLE SIGNUP ERROR: $e');
      debugPrintStack(stackTrace: st);

      setState(() {
        _errorText = 'Could not create account: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleDriverSelection() async {
    await _createAccountAndRoute(
      role: 'driver',
      routeName: '/dashboard',
    );
  }

  Future<void> _handleOperatorSelection() async {
    await _createAccountAndRoute(
      role: 'operator',
      routeName: '/fleet-dashboard',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DriverSafetyApp.of(context).isDark;
    final bgTop = isDark ? const Color(0xFF0D1117) : const Color(0xFFCED8E4);
    final bgBottom = isDark ? const Color(0xFF1A2332) : const Color(0xFF7E97B9);

    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark
        ? Colors.white.withOpacity(0.72)
        : Colors.black.withOpacity(0.7);

    final cardColor = isDark
        ? const Color(0xFF142033)
        : Colors.white.withOpacity(0.96);

    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.08);

    final primaryColor =
        isDark ? const Color(0xFF6E95DC) : const Color(0xFF5E8AD6);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose your role'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgTop, bgBottom],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'BLINK',
                      style: GoogleFonts.megrim(
                        fontSize: 44,
                        letterSpacing: 10,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "Select how you'll use the platform",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 34),
                    _RoleCard(
                      title: 'Fleet Driver',
                      subtitle:
                          'Receive fatigue alerts and access your live monitoring tools.',
                      icon: Icons.drive_eta_rounded,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      accentColor: primaryColor,
                      onTap: _isLoading ? null : _handleDriverSelection,
                    ),
                    const SizedBox(height: 18),
                    _RoleCard(
                      title: 'Fleet Operator',
                      subtitle:
                          'Monitor drivers, review alerts, and manage your fleet dashboard.',
                      icon: Icons.dashboard_customize_rounded,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      accentColor: primaryColor,
                      onTap: _isLoading ? null : _handleOperatorSelection,
                    ),
                    if (_isLoading) ...[
                      const SizedBox(height: 22),
                      const CircularProgressIndicator(),
                    ],
                    if (_errorText != null) ...[
                      const SizedBox(height: 18),
                      Text(
                        _errorText!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFFF6B6B),
                          fontSize: 14,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: Text(
                        'Back',
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color cardColor;
  final Color borderColor;
  final Color textColor;
  final Color accentColor;
  final VoidCallback? onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: accentColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: textColor.withOpacity(0.72),
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: textColor.withOpacity(0.65),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}