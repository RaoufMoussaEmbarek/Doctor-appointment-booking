


import 'dart:convert';

import 'package:appointment_app/domain/entities/Slot.dart';
import 'package:appointment_app/domain/repositories/slot_repository.dart';
import 'package:appointment_app/infrastructure/api/api_client.dart';



class SlotApiRepository implements SlotRepository{

   final ApiClient api;

   SlotApiRepository(this.api);

   @override
   Future <List<Slot>> getSlots( { required int doctorId,
  required date}) async {

     final d = date.toIso8601String().substring(0, 10);
     
       final res = await api.get('/doctors/$doctorId/availability?date=$d');
   
   if (res.statusCode == 200) {
    final List<dynamic> times = jsonDecode(res.body);

    final List<Slot> slots;

   slots =  times.map((time) {
      final parts = (time as String).split(':');
    
      final start = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

     

      return Slot(
        start: start,
        end: start.add(const Duration(minutes: 30)),
      );
    }).toList();
   
   
    return slots;
  } else {
    throw Exception('Failed to load availability');
  }


  }
}