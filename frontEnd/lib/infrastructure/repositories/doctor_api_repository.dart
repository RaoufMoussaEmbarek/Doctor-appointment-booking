import 'dart:convert';

import 'package:appointment_app/domain/entities/doctor.dart';
import 'package:appointment_app/domain/repositories/doctor_repository.dart';
import 'package:appointment_app/infrastructure/api/api_client.dart';



class DoctorApiRepository implements DoctorRepository {

  final ApiClient api;

  DoctorApiRepository(this.api);


  @override
  Future<List<Doctor>> getDoctors() async {
     final res = await api.get('/doctors');
   
  if (res.statusCode != 200) {
      throw Exception('FAILED_TO_LOAD_Doctors');
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => Doctor.fromJson(e)).toList();
  }


}
