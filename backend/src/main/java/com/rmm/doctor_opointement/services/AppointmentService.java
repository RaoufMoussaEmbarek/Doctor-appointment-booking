package com.rmm.doctor_opointement.services;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import com.rmm.doctor_opointement.model.Appointment;
import com.rmm.doctor_opointement.model.Doctor;
import com.rmm.doctor_opointement.model.Patient;
import com.rmm.doctor_opointement.repository.AppointmentRepository;

import jakarta.transaction.Transactional;

@Service
public class AppointmentService {

    private final AppointmentRepository appointmentRepository;

    public AppointmentService(AppointmentRepository appointmentRepository) {
        this.appointmentRepository = appointmentRepository;
    }

    // ================= CREATE =================
    @Transactional
    public Appointment create(
            Patient patient,
            Doctor doctor,
            LocalDateTime start,
            LocalDateTime end
    ) {
        boolean conflict =
                appointmentRepository.existsOverlapping(
                        doctor, start, end
                );

        if (conflict) {
            throw new IllegalStateException("Time slot not available");
        }

        Appointment appointment = new Appointment();       
        appointment.setPatient(patient);
        appointment.setDoctor(doctor);
        appointment.setStartTime(start);
        appointment.setEndTime(end);
        appointment.setStatus("CONFIRMED");
        appointment.setCreatedAt(LocalDateTime.now());

        return appointmentRepository.save(appointment);
    }

    // ================= READ =================
    public List<Appointment> findByPatient(Patient patient) {
        return appointmentRepository.findByPatient(patient);
    }

    // ================= CANCEL =================
    @Transactional
    public void cancelByPatient(Long appointmentId, Patient patient) {

        System.out.print("trying to cancel"+appointmentId+"for patient " + patient);

        Appointment a = appointmentRepository.findById(appointmentId)
                .orElseThrow(() -> new RuntimeException("Appointment not found"));

        if (!a.getPatient().equals(patient)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,"Forbidden");
        }

        if (a.getStartTime().isBefore(LocalDateTime.now().plusHours(1))) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Too late to cancel");
        }

        a.setStatus("CANCELLED");
        appointmentRepository.save(a);
    }

    // ================= RESCHEDULE =================
    @Transactional
    public Appointment rescheduleByPatient(
            Long appointmentId,
            Patient patient,
            LocalDateTime newStart,
            LocalDateTime newEnd
    ) {

        Appointment old = appointmentRepository.findById(appointmentId)
                .orElseThrow(() -> new RuntimeException("Appointment not found"));

        if (!old.getPatient().equals(patient)) {
            throw new RuntimeException("Forbidden");
        }

        if (old.getStartTime().isBefore(LocalDateTime.now().plusHours(1))) {
            throw new RuntimeException("Too late to modify");
        }

        boolean conflict =
                appointmentRepository.existsOverlappingExcluding(
                        old.getDoctor(),
                        newStart,
                        newEnd,
                        old.getId()
                );

        if (conflict) {
            throw new IllegalStateException("Time slot not available");
        }

        old.setStartTime(newStart);
        old.setEndTime(newEnd);

        return appointmentRepository.save(old);
    }

    /**
     * @param doctorId
     * @param start
     * @param end
     * @return
     */
    public boolean isSlotFree(
        Doctor doctor,
        LocalDateTime start,
        LocalDateTime end
) {
    return !appointmentRepository.existsOverlapping(
            doctor, start, end
    );
}

}
