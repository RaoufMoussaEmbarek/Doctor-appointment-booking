import 'package:flutter/material.dart';
import 'package:appointment_app/pages/appointments_page.dart';
import 'package:appointment_app/pages/My_appointments_page.dart';
import 'package:appointment_app/pages/login_page.dart';
import 'package:appointment_app/infrastructure/api/api.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = true;
  Map<String, dynamic>? nextAppointment;

  @override
  void initState() {
    super.initState();
    loadNextAppointment();
  }

  Future<void> loadNextAppointment() async {
    try {
      final list = await getMyAppointments();

      final now = DateTime.now();

      final upcoming = list
          .where((a) =>
              DateTime.parse(a['startTime']).isAfter(now))
          .toList();

      upcoming.sort((a, b) =>
          DateTime.parse(a['startTime'])
              .compareTo(DateTime.parse(b['startTime'])));

      setState(() {
        nextAppointment = upcoming.isNotEmpty ? upcoming.first : null;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        nextAppointment = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
         SafeArea(
  child: RefreshIndicator(
  onRefresh: loadNextAppointment,
  child: LayoutBuilder(
    builder: (context, constraints) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
          ),
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  Text(
                    'Stay Healthy',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your health easily',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Next appointment hero
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: loading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : nextAppointment != null
                            ? _NextAppointmentCard(
                            appointment: nextAppointment!,
                            onRefresh: loadNextAppointment,
                          )
                            : const _NoAppointmentCard(),
                  ),

                  const SizedBox(height: 32),

                  // Actions
                  Text(
                    'Actions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.add_circle_outline,
                          title: 'New Appointment',
                          subtitle: 'Choose a doctor',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AppointmentsPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.calendar_today,
                          title: 'My Appointments',
                          subtitle: 'View & manage',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MyAppointmentsPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 120),
                ],
              ),
              
            ),
          ),);},),),),

          // Logout
          Positioned(
            left: 20,
            bottom: 20,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () async {
                await clearToken();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                  (_) => false,
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Text('Logout',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextAppointmentCard extends StatelessWidget {
  final Map appointment;

   final VoidCallback onRefresh;

  const _NextAppointmentCard({
    required this.appointment,
    required this.onRefresh,
  });



  @override
  Widget build(BuildContext context) {
    final start = DateTime.parse(appointment['startTime']);
    final now = DateTime.now();
    final daysLeft = start.difference(now).inDays;
    

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Next Appointment',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Text(
          appointment['doctor']['name'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          appointment['doctor']['speciality'],
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Text(
          daysLeft == 0
              ? 'Today at ${DateFormat.Hm().format(start)}'
              : 'In $daysLeft days',
          style: const TextStyle(color: Colors.white),
        ),
         
      ],
    );
  }
}

class _NoAppointmentCard extends StatelessWidget {
    
  const _NoAppointmentCard();



  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'No upcoming appointment',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Book a doctor in a few seconds',
          style: TextStyle(color: Colors.white70),
        ),
      
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.shade100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
