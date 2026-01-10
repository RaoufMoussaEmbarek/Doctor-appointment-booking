import 'package:appointment_app/domain/entities/Slot.dart';
import 'package:appointment_app/domain/repositories/slot_repository.dart';

class GetSlots {
  final SlotRepository repository;

  GetSlots(this.repository);

  Future <List<Slot>> call({
     required int doctorId,
 required DateTime date,
  }){

    return repository.getSlots(doctorId: doctorId, date: date);
  }

}