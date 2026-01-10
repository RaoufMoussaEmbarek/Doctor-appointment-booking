import 'package:appointment_app/application/use_cases/get_doctors.dart';
import 'package:appointment_app/domain/entities/doctor.dart';
import 'package:appointment_app/infrastructure/api/api_client.dart';

import 'package:appointment_app/infrastructure/repositories/doctor_api_repository.dart';
import 'package:flutter/material.dart';

import 'package:appointment_app/pages/doctor_calendar_page.dart';

class AppointmentsPage extends StatefulWidget {
  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  List<Doctor> doctors = [];
 
  bool loading = true;

  @override
  void initState() {
    super.initState();
   
    loadDoctors();
  }

  Future<void> loadDoctors() async {

      final api = ApiClient();
      await api.loadToken();

      final repo = DoctorApiRepository(api);
    final useCase_doctors = GetDoctors(repo);
    final data = await useCase_doctors();

    setState(() {
      doctors = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Doctor'),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: doctors.length,
                itemBuilder: (context, i) {
                  final d = doctors[i];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      title: Text(
                        d.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          d.speciality,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                     
                        // next step: open calendar
                        onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DoctorCalendarPage(doctor: d),
                          ),
                        );
                      },
                    
                    ),
                  );
                },
              ),
            ),
    );
  }
}
