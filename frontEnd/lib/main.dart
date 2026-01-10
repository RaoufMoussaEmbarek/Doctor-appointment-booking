import 'package:appointment_app/infrastructure/api/api.dart';
import 'package:appointment_app/infrastructure/repositories/auth_gate.dart';

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


