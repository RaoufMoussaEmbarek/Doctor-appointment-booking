ALTER TABLE patients
ADD COLUMN user_id BIGINT UNIQUE,
ADD CONSTRAINT fk_patients_user
FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE doctors
ADD COLUMN user_id BIGINT UNIQUE,
ADD CONSTRAINT fk_doctors_user
FOREIGN KEY (user_id) REFERENCES users(id);