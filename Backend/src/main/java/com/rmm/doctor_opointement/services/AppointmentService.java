package com.rmm.doctor_opointement.services;


import com.rmm.doctor_opointement.model.appointment;


import org.springframework.stereotype.Service;


import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.Collectors;

@Service
public class AppointmentService {

    private final List<appointment> appointments = new ArrayList<>();
    private final AtomicLong idGenerator = new AtomicLong(1);

    public appointment create(
            Long patientId,
            Long doctorId,
            LocalDateTime start,
            LocalDateTime end
    ) {
        // Check overlap
        boolean conflict = appointments.stream().anyMatch(a ->
            a.doctorId().equals(doctorId) &&
            a.startTime().isBefore(end) &&
            start.isBefore(a.endTime())
        );

        if (conflict) {
            throw new IllegalStateException("Time slot not available");
        }

        appointment appointment = new appointment(
            idGenerator.getAndIncrement(),
            patientId,
            doctorId,
            start,
            end
        );

        appointments.add(appointment);
        return appointment;
    }

    public List<appointment> findByPatient(Long patientId) {
        return appointments.stream()
                .filter(a -> a.patientId().equals(patientId))
                .collect(Collectors.toList());
    }

    public boolean isFree(Long doctorId, String date, String time) {
    return appointments.stream().noneMatch(a ->
        a.doctorId().equals(doctorId) &&
        a.startTime().toLocalDate().toString().equals(date) &&
        a.startTime().toLocalTime().toString().startsWith(time)
    );
}

public void cancelByPatient(Long appointmentId, Long patientId) {

    appointment a = appointments.stream()
        .filter(ap -> ap.id().equals(appointmentId))
        .findFirst()
        .orElseThrow(() -> new RuntimeException("Appointment not found"));

    if (!a.patientId().equals(patientId)) {
        throw new RuntimeException("Forbidden");
    }

    if (a.startTime().isBefore(LocalDateTime.now().plusHours(1))) {
        throw new RuntimeException("Too late to cancel");
    }

    // remove appointment (slot becomes free)
    appointments.remove(a);
}

public appointment rescheduleByPatient(
        Long appointmentId,
        Long patientId,
        LocalDateTime newStart,
        LocalDateTime newEnd
) {

    appointment old = appointments.stream()
        .filter(ap -> ap.id().equals(appointmentId))
        .findFirst()
        .orElseThrow(() -> new RuntimeException("Appointment not found"));

    if (!old.patientId().equals(patientId)) {
        throw new RuntimeException("Forbidden");
    }

    if (old.startTime().isBefore(LocalDateTime.now().plusHours(1))) {
        throw new RuntimeException("Too late to modify");
    }

    // check conflicts (EXCLUDE current appointment)
    boolean conflict = appointments.stream().anyMatch(a ->
        !a.id().equals(old.id()) &&
        a.doctorId().equals(old.doctorId()) &&
        a.startTime().isBefore(newEnd) &&
        newStart.isBefore(a.endTime())
    );

    if (conflict) {
        throw new IllegalStateException("Time slot not available");
    }

    // replace appointment
    appointments.remove(old);

    appointment updated = new appointment(
        old.id(),
        old.patientId(),
        old.doctorId(),
        newStart,
        newEnd
    );

    appointments.add(updated);
    return updated;
}



}

