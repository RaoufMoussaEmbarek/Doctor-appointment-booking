import 'package:appointment_app/application/use_cases/cancel_appointment.dart';
import 'package:appointment_app/application/use_cases/reschedule_appointment.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:appointment_app/application/use_cases/get_my_appointments.dart';
import 'package:appointment_app/domain/entities/Appointment.dart';
import 'package:appointment_app/infrastructure/api/api_client.dart';
import 'package:appointment_app/infrastructure/repositories/appointment_api_repository.dart';

class MyAppointmentsPage extends StatefulWidget {
  @override
  State<MyAppointmentsPage> createState() => _MyAppointmentsPageState();
}

class _MyAppointmentsPageState extends State<MyAppointmentsPage> {
  List<Appointment> appointments = [];
  late final sortedAppointments = List<Appointment>.from(appointments);
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final api = ApiClient();
      await api.loadToken();
      final repo = AppointmentApiRepository(api);
      final useCase = GetMyAppointments(repo);
      final data = await useCase();
      setState(() {
        appointments = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = 'Failed to load appointments';
      });

      print("error is:" + e.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

   int appointmentPriority(Appointment a) {
  if (a.status == 'CONFIRMED' && a.endTime.isAfter(DateTime.now())) {
    return 0; // upcoming confirmed
  }
  if (a.status == 'CONFIRMED') {
    return 1; // past confirmed (expired)
  }
  return 2; // cancelled
}

final now = DateTime.now();

sortedAppointments.sort((a, b) {
 
  final p =
      appointmentPriority(a).compareTo(appointmentPriority(b));
  if (p != 0) return p;


  final aDiff = a.startTime.difference(now).abs();
  final bDiff = b.startTime.difference(now).abs();

  return aDiff.compareTo(bDiff);
});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'My Appointments',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Manage your upcoming consultations',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : error != null
                        ? Center(
                            child: Text(
                              error!,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          )
                        : appointments.isEmpty
                            ? _EmptyState()
                            : ListView.builder(
                                itemCount: sortedAppointments.length,
                                itemBuilder: (context, i) {
                                  final a = sortedAppointments[i];
                                  return _AppointmentCard(
                                    appointmentId: a.id,
                                    doctorName: a.name,
                                    speciality: a.speciality,
                                    backendStatus: a.backendStatus!,
                                    start: a.startTime,
                                    end: a.endTime,
                                    onChanged: loadAppointments,
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum AppointmentState {
  confirmed,
  cancelled,
  expired,
}

class _AppointmentCard extends StatelessWidget {
  final int appointmentId;
  final String doctorName;
  final String speciality;
  final String backendStatus;
  final DateTime start;
  final DateTime end;
  final VoidCallback onChanged;

  const _AppointmentCard({
    required this.appointmentId,
    required this.doctorName,
    required this.speciality,
    required this.backendStatus,
    required this.start,
    required this.end,
    required this.onChanged,
  });

  AppointmentState get _state {
  if (backendStatus == 'CANCELLED') {
    return AppointmentState.cancelled;
  }
  if (end.isBefore(DateTime.now())) {
    return AppointmentState.expired;
  }
  return AppointmentState.confirmed;
}

 bool get _actionsEnabled => _state == AppointmentState.confirmed;

  @override
  Widget build(BuildContext context) {
    final startDt = start;
    final endDt = end;

    Color _stateColor(BuildContext context) {
  switch (_state) {
    case AppointmentState.cancelled:
      return Colors.red;
    case AppointmentState.expired:
      return Colors.grey;
    case AppointmentState.confirmed:
      return Theme.of(context).colorScheme.primary;
  }
}

String _stateLabel() {
  switch (_state) {
    case AppointmentState.cancelled:
      return 'Cancelled';
    case AppointmentState.expired:
      return 'Expired';
    case AppointmentState.confirmed:
      return 'Confirmed';
  }
}



    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                     _stateColor(context).withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.calendar_today,
                color: _stateColor(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctorName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    speciality,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${DateFormat.yMMMd().format(startDt)} • '
                    '${DateFormat.Hm().format(startDt)} - '
                    '${DateFormat.Hm().format(endDt)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
            
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _stateColor(context).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _stateLabel(),
                      style: TextStyle(
                        fontSize: 12,
                        color: _stateColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_actionsEnabled)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.primary),
              onSelected: (value) {
                if (value == 'cancel') {
                  _confirmCancel(context);
                }
                if (value == 'modify') {
                  _confirmModify(context);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'modify',
                  child: Text('Modify'),
                ),
                PopupMenuItem(
                  value: 'cancel',
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel appointment'),
        content:
            const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                
              final api = ApiClient();
              await api.loadToken();
              print("trying to cancel client with token $api");
              final repo = AppointmentApiRepository(api);
              final useCase = CancelAppointment(repo);
              await useCase(appointmentId);
              onChanged();
            } catch (e){
                 ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    e.toString().replaceAll('Exception: ', ''),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            },
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );
  }
void _confirmModify(BuildContext context) {


  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Modify appointment'),
      content: const Text(
        'are you sure you want to move the appointment to the NEXT DAY? do you want to Continue?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('No'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            try {
              final api = ApiClient();
              await api.loadToken();
              final reop = AppointmentApiRepository(api);
              final useCase_reschedule = RescheduleAppointment(reop);

            

            await useCase_reschedule(
              appointmentId: appointmentId,
              newStart: start.add(const Duration(days: 1)),
              newEnd: end.add(const Duration(days: 1)),
            );

            onChanged();
          } catch (e){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    e.toString().replaceAll('Exception: ', ''),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: const Text('Yes'),
        ),
      ],
    ),
  );
}

}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No appointments yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Book a doctor to get started',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
