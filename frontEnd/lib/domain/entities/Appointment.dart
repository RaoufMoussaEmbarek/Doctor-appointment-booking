class Appointment {
  final int id;
  final String name;
  final String speciality;
  final String? backendStatus;
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  Appointment({
    required this.id,
    required this.name,
    required this.speciality,
    required this.backendStatus,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      name: json['doctor']?['name'] ?? 'Unknown',
      speciality: json['doctor']?['speciality'] ?? 'Unknown',
      backendStatus: json['status'] ?? 'Unknown',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      status: json['status'] ?? 'Unknown',
    );
  }
}
