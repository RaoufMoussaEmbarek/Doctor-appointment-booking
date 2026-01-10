import 'package:appointment_app/domain/entities/Slot.dart';

abstract class SlotRepository {
  

  Future <List<Slot>> getSlots({
    required DateTime date,
  required int doctorId,
 
});

}