import 'package:appointment_app/infrastructure/api/api.dart';
import 'package:flutter/material.dart';

import '../../pages/login_page.dart';
import '../../pages/home_page.dart';

class AuthGate extends StatefulWidget {
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool loading = true;

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  Future<void> checkAuth() async {
    await loadToken();
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return jwt == null ? LoginPage() : HomePage();
  }
}
