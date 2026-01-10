import 'package:appointment_app/domain/entities/doctor.dart';



abstract class DoctorRepository {
  Future<List<Doctor>> getDoctors();
}
