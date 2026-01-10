import '../../domain/repositories/appointment_repository.dart';

class RescheduleAppointment {
  final AppointmentRepository repo;

  RescheduleAppointment(this.repo);

  Future<void> call({
    required int appointmentId,
    required DateTime newStart,
    required DateTime newEnd,
  }) {
    return repo.reschedule(
      appointmentId: appointmentId,
      newStart: newStart,
      newEnd: newEnd,
    );
  }
}
