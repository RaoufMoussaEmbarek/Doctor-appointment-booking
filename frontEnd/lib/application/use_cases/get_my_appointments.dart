import 'package:appointment_app/domain/entities/Appointment.dart';


import '../../domain/repositories/appointment_repository.dart';

class GetMyAppointments {
  final AppointmentRepository repo;

  GetMyAppointments(this.repo);

  Future<List<Appointment>> call() {
    return repo.getMyAppointments();
  }
}
