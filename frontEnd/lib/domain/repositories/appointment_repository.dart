import 'package:appointment_app/domain/entities/Appointment.dart';



abstract class AppointmentRepository {
  Future<List<Appointment>> getMyAppointments();

  Future<void> cancel(int appointmentId);

    Future<void> reschedule({
    required int appointmentId,
    required DateTime newStart,
    required DateTime newEnd,
  });
}
