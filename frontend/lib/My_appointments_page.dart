import 'package:flutter/material.dart';
import 'api.dart';
import 'package:intl/intl.dart';

class MyAppointmentsPage extends StatefulWidget {
  @override
  State<MyAppointmentsPage> createState() => _MyAppointmentsPageState();
}

class _MyAppointmentsPageState extends State<MyAppointmentsPage> {
  List appointments = [];
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
      final data = await getMyAppointments();
      setState(() {
        appointments = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = 'Failed to load appointments';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
                                itemCount: appointments.length,
                                itemBuilder: (context, i) {
                                  final a = appointments[i];
                                  return _AppointmentCard(
                                    appointmentId: a['id'],
                                    doctorName: a['doctor']['name'],
                                    speciality: a['doctor']['speciality'],
                                    start: a['startTime'],
                                    end: a['endTime'],
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

class _AppointmentCard extends StatelessWidget {
  final int appointmentId;
  final String doctorName;
  final String speciality;
  final String start;
  final String end;
  final VoidCallback onChanged;

  const _AppointmentCard({
    required this.appointmentId,
    required this.doctorName,
    required this.speciality,
    required this.start,
    required this.end,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final startDt = DateTime.parse(start);
    final endDt = DateTime.parse(end);

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
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.calendar_today,
                color: Theme.of(context).colorScheme.primary,
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
                ],
              ),
            ),
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
              await cancelAppointment(appointmentId);
              onChanged();
            },
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );
  }
void _confirmModify(BuildContext context) {
  final startDt = DateTime.parse(start);
  final endDt = DateTime.parse(end);

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

            await rescheduleAppointment(
              appointmentId: appointmentId,
              newStart: startDt.add(const Duration(days: 1)),
              newEnd: endDt.add(const Duration(days: 1)),
            );

            onChanged();
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
