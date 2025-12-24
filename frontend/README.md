# appointment_app

Flutter Application

This Flutter application provides the patient-facing interface of the secure appointment booking system.

It allows users to:

Authenticate securely using JWT

View upcoming appointments

Book consultations based on doctor availability

Cancel or reschedule existing appointments

Refresh appointment data with pull-to-refresh gestures

The app communicates with a Spring Boot backend via REST APIs and handles loading states, errors, and session expiration gracefully.
All sensitive logic and business rules are enforced by the backend to ensure security.
