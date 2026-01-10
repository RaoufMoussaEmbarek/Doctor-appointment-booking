import 'dart:convert';
import 'package:appointment_app/domain/entities/Appointment.dart';
import 'package:appointment_app/infrastructure/api/api_client.dart';


import '../../domain/repositories/appointment_repository.dart';


class AppointmentApiRepository implements AppointmentRepository {
  final ApiClient api;

  AppointmentApiRepository(this.api);

  @override
  Future<List<Appointment>> getMyAppointments() async {
    final res = await api.get('/appointments/me');

    print("this is the body : "+res.body);

    if (res.statusCode != 200) {
      throw Exception('FAILED_TO_LOAD_APPOINTMENTS');
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => Appointment.fromJson(e)).toList();
  }

  @override
Future<void> cancel(int appointmentId) async {
  print("cancel request sent id:$appointmentId");
  final res = await api.put('/appointments/$appointmentId/cancel');

  print("request body : ${res.body}");

   if (res.statusCode < 200 || res.statusCode >= 300) {
    throw Exception(
      res.body.isEmpty ? 'CANCEL_FAILED' : res.body,
    );
  }
}

@override
Future<void> reschedule({
  required int appointmentId,
  required DateTime newStart,
  required DateTime newEnd,
}) async {
  final res = await api.put(
    '/appointments/$appointmentId/reschedule',
    body: {
      'startTime': newStart.toIso8601String(),
      'endTime': newEnd.toIso8601String(),
    },
  );

  if (res.statusCode != 200) {
    throw Exception(
      res.body.isEmpty ? 'RESCHEDULE_FAILED' : res.body,
    );
  }
}
}
