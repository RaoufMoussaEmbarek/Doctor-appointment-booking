import 'dart:convert';
import 'package:appointment_app/pages/login_page.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';




// Android emulator -> localhost of your PC
const String baseUrl = 'http://10.0.2.2:8081';

String? jwt;



final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

Future<void> login(String email,String password) async {

   
  final response = await http.post(
    
    Uri.parse('$baseUrl/auth/login'),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
       "email": email,
  "password": password
    }),
  );


     

  if (response.statusCode == 200) {
    final token = jsonDecode(response.body)['accessToken'];
    await saveToken(token);
  } else if (response.statusCode == 401){
    throw Exception("INVALID_CREDENTIALS") ;
  } else if (response.statusCode == 403) {
    throw Exception("USER_DISABLED");
  } else  {
    throw Exception("SERVER_ERROR");
  }




}



Future<List<dynamic>> getMyAppointments() async {
  final response = await authorizedRequest(
    (token)=>  http.get(
    Uri.parse('$baseUrl/appointments/me'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  ));

  print(response.statusCode);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load appointments');
  }
}

Future<void> createAppointment() async {
  final response = await authorizedRequest(
    (token) =>  http.post(
    Uri.parse('$baseUrl/appointments'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'doctorId': 1,
      'startTime': '2025-01-10T10:00',
      'endTime': '2025-01-10T10:30',
    }),
  ));

  if (response.statusCode != 200) {
    // pass backend error to UI
    throw Exception(response.body);
  }
}

Future<List<dynamic>> getDoctors() async {
  final response = await http.get(
    Uri.parse('$baseUrl/doctors'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load doctors');
  }
}



Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('jwt', token);
  jwt = token;
}

Future<void> loadToken() async {
  final prefs = await SharedPreferences.getInstance();
  jwt = prefs.getString('jwt');
}

Future<void> clearToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('jwt');
  jwt = null;
}

Future<List<String>> getAvailability(
  int doctorId,
  DateTime date,
) async {
  final d = date.toIso8601String().substring(0, 10);

  final res = await http.get(
    Uri.parse('$baseUrl/doctors/$doctorId/availability?date=$d'),
  );

  if (res.statusCode == 200) {
    return List<String>.from(jsonDecode(res.body));
  } else {
    throw Exception('Failed to load availability');
  }
}

Future<void> bookAppointment({
  required int doctorId,
  required DateTime date,
  required String time,
}) async {
  await loadToken(); // 👈 VERY IMPORTANT

  if (jwt == null) {
    throw Exception('NOT_AUTHENTICATED');
  }

   

  final start = DateTime.parse(
    '${date.toIso8601String().substring(0, 10)}T$time',
  );
  final end = start.add(const Duration(minutes: 30));

  final res = await authorizedRequest(
    (token) =>  http.post(
    Uri.parse('$baseUrl/appointments'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'doctorId': doctorId,
      'startTime': start.toIso8601String(),
      'endTime': end.toIso8601String(),
    }),
  
  ));


  if (res.statusCode == 401) {
    throw Exception('UNAUTHORIZED');
  }

  if (res.statusCode != 200) {

    print(res.body);
    throw Exception(
      res.body.isEmpty ? 'Booking failed' : res.body,
    );
  }
}

Future<http.Response> authorizedRequest(
  Future<http.Response> Function(String token) request,
) async {
  

  if (jwt == null) {
       navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginPage()),
      (_) => false,
    );
    throw Exception('UNAUTHORIZED');
  }

  final res = await request(jwt!);

  if (res.statusCode == 401) {
    await clearToken();

 WidgetsBinding.instance.addPostFrameCallback((_) {
  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => LoginPage()),
    (_) => false,
  );
});

    throw Exception('SESSION_EXPIRED');
  }

  return res;
}

Future<void> cancelAppointment(int appointmentId) async {
  final res = await authorizedRequest(
    (token) => http.put(
      Uri.parse('$baseUrl/appointments/$appointmentId/cancel'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    ),
  );

  if (res.statusCode != 200) {
    throw Exception(
      res.body.isEmpty ? 'Cancel failed' : res.body,
    );
  }
}

Future<void> rescheduleAppointment({
  required int appointmentId,
  required DateTime newStart,
  required DateTime newEnd,
}) async {
  final res = await authorizedRequest(
    (token) => http.put(
      Uri.parse('$baseUrl/appointments/$appointmentId/reschedule'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'startTime': newStart.toIso8601String(),
        'endTime': newEnd.toIso8601String(),
      }),
    ),
  );

  if (res.statusCode != 200) {
    throw Exception(
      res.body.isEmpty ? 'Reschedule failed' : res.body,
    );
  }
}





