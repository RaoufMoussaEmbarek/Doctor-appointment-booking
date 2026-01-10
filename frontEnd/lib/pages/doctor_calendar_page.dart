import 'package:appointment_app/application/use_cases/get_slots.dart';
import 'package:appointment_app/domain/entities/Slot.dart';
import 'package:appointment_app/domain/entities/doctor.dart';
import 'package:appointment_app/infrastructure/api/api_client.dart';
import 'package:appointment_app/infrastructure/repositories/slot_api_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:appointment_app/infrastructure/api/api.dart';

class DoctorCalendarPage extends StatefulWidget {
  final Doctor doctor;

  const DoctorCalendarPage({
    super.key,
    required this.doctor,
  });

  @override
  State<DoctorCalendarPage> createState() => _DoctorCalendarPageState();
}

class _DoctorCalendarPageState extends State<DoctorCalendarPage> {
  DateTime currentMonth = DateTime.now();
  DateTime selectedDate = DateTime.now();

  List<Slot> slots = [];
  bool loadingSlots = false;

  String? bookingSlot;
  String? confirmedSlot;

  @override
  void initState() {
    super.initState();
    loadSlots();
  }

  Future<void> loadSlots() async {
    setState(() => loadingSlots = true);

    try {
       
  final api = ApiClient();
      await api.loadToken();

      final repo = SlotApiRepository(api);
      final useCaseSlots = GetSlots(repo);



      slots = await useCaseSlots(
       doctorId:  widget.doctor.id,
       date:  selectedDate,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loadingSlots = false);
      }
    }
  }

  /// Slot is bookable only if it is at least +1 hour from now
  bool isSlotBookable(Slot slot) {
    

    final slotTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      slot.start.hour,
      slot.end.hour,
    );

    final limit = DateTime.now().add(const Duration(hours: 1));
    return slotTime.isAfter(limit);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysInMonth =
        DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Select Date',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

             
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.85),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.doctor.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.doctor.speciality,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Month selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        currentMonth = DateTime(
                          currentMonth.year,
                          currentMonth.month - 1,
                        );
                      });
                    },
                  ),
                  Text(
                    DateFormat.yMMMM().format(currentMonth),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        currentMonth = DateTime(
                          currentMonth.year,
                          currentMonth.month + 1,
                        );
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Calendar grid
              GridView.builder(
                shrinkWrap: true,
                itemCount: daysInMonth,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (_, i) {
                  final day = DateTime(
                    currentMonth.year,
                    currentMonth.month,
                    i + 1,
                  );

                  final isSelected =
                      DateUtils.isSameDay(day, selectedDate);

                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedDate = day);
                      loadSlots();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.grey.shade100,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Slots header
              Text(
                'Available slots',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // Slots grid
              Expanded(
                child: loadingSlots
                    ? const Center(child: CircularProgressIndicator())
                    : slots.isEmpty
                        ? Center(
                            child: Text(
                              'No available slots',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          )
                        : GridView.count(
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            children: slots.map((slot) {
                              final isBooking = bookingSlot == DateFormat('HH:mm').format(slot.start);
                              final isConfirmed = confirmedSlot == DateFormat('HH:mm').format(slot.start);
                              final canBook = isSlotBookable(slot);

                              return GestureDetector(
                                onTap: (!canBook || isBooking || isConfirmed)
                                    ? null
                                    : () async {
                                        final confirmed =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text(
                                                'Confirm appointment'),
                                            content: Text(
                                              'Book ${widget.doctor.name} on '
                                              '${DateFormat.yMMMd().format(selectedDate)} at $slot?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                        context, false),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                        context, true),
                                                child: const Text('Confirm'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmed != true) return;

                                        setState(() => bookingSlot = DateFormat('HH:mm').format(slot.start));

                                        

                                        try {
                                          await bookAppointment(
                                            doctorId:
                                                widget.doctor.id,
                                            date: selectedDate,
                                            time: DateFormat('HH:mm').format(slot.start),
                                          );

                                          print("hello sloot""${slot.start}");

                                          if (!mounted) return;

                                          setState(() {
                                            confirmedSlot = DateFormat('HH:mm').format(slot.start);
                                            bookingSlot = null;
                                          });

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Booking confirmed'),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        } catch (e) {
                                          if (!mounted) return;
                                          setState(
                                              () => bookingSlot = null);

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content:
                                                    Text(e.toString())),
                                          );
                                        }
                                      },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(14),
                                    color: isConfirmed
                                        ? Colors.green.shade400
                                        : !canBook
                                            ? Colors.grey.shade300
                                            : isBooking
                                                ? Colors.grey.shade300
                                                : Colors.grey.shade100,
                                  ),
                                  child: isBooking
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          isConfirmed
                                              ? 'Booked'
                                              : !canBook
                                                  ? 'Unavailable'
                                                  : DateFormat('HH:mm').format(slot.start),
                                          style: TextStyle(
                                            color: isConfirmed
                                                ? Colors.white
                                                : !canBook
                                                    ? Colors
                                                        .grey.shade600
                                                    : Colors.black,
                                            fontWeight:
                                                FontWeight.w500,
                                          ),
                                        ),
                                ),
                              );
                            }).toList(),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
