Architecture

The application uses a client–server architecture with a clear separation between frontend and backend.

Flutter (Frontend)
Handles the user interface, navigation, and user interactions.
It communicates with the backend via HTTP and attaches a JWT to protected requests.

Spring Boot (Backend)
Handles authentication, security, and business logic.
JWTs are validated on every request using Spring Security, and all business rules are enforced server-side.

Security
Authentication is stateless and JWT-based.
Users can only access their own appointments, and the backend never trusts client data.

Flutter App → Spring Boot API → Business Logic

Details: 

- Jwt Tokens contain:
  - user ID
  - role
  - expiration
- Appointment endpoints are protected
- Users can only access their own appointments, have no controel over security data
- JWT expires automatically (30 minutes) to minize risk incase token exposed
- Client is redirected to login on expiration, no auto refrech jwt token (due to short time)

flutter app features: 
- Book an appointment based on availability
- View personal appointments
- Cancel appointment
- Reschedule appointment
- Secure access control
- Modern and responsive UI

behavior protection and control: 
- A user can only view and manage their own appointments
- Appointments cannot overlap
- Appointments cannot be booked in the past
- Availability is revalidated server-side
- Backend ignores any client-side manipulation



## How to Run

### Backend
cd backend
./mvnw spring-boot:run


### frontend
cd frontend
flutter pub get
flutter run
For emulator, the backend runs on http://10.0.2.2:8081
need to change localhost adresse in the baseURL of the api.dart file to your computer local host

Trade-offs & Limitations (possible improvments)
No database (in-memory storage only)
No refresh tokens (re-login on expiration)
Doctor availability is mocked
no entry control
no user profile

