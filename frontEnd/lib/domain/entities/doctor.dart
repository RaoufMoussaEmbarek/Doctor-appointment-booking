class Doctor {
  final int id;
  final String name;
  final String speciality;

  Doctor({
    required this.id,
    required this.name,
    required this.speciality,
  });

    factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      speciality: json['speciality'] ?? 'Unknown',
  
    );
  }
}