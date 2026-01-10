import '../../domain/repositories/appointment_repository.dart';

class CancelAppointment {
  final AppointmentRepository repo;

  CancelAppointment(this.repo);

  Future<void> call(int appointmentId) {
    return repo.cancel(appointmentId);
  }
}
