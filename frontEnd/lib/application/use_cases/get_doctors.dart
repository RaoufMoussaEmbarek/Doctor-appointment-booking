
import 'package:appointment_app/domain/entities/doctor.dart';
import 'package:appointment_app/domain/repositories/doctor_repository.dart';

class GetDoctors {
  final DoctorRepository repository;

  GetDoctors(this.repository);

  Future<List<Doctor>> call() {
    return repository.getDoctors();
  }
}