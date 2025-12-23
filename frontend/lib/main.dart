import 'package:appointment_app/api.dart';
import 'package:appointment_app/auth_gate.dart';

import 'package:flutter/material.dart';


void main() {
  runApp(
     MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: AuthGate(),
    ),
  );
}
