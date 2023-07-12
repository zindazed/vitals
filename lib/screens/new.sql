CREATE TABLE `users` (
  `user_id` int(50) NOT NULL AUTO_INCREMENT,
  `user_name` varchar(50) NOT NULL,
  `password` varchar(200) NOT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci

CREATE TABLE `patients` (
  `dob` date NOT NULL,
  `device_id` int(50) NOT NULL,
  `patient_id` int(50) NOT NULL,
  `secret_code` int(5) DEFAULT NULL,
  PRIMARY KEY (`device_id`),
  KEY `patient_id` (`patient_id`),
  CONSTRAINT `patients_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci

CREATE TABLE `caretakers` (
  `caretaker_id` int(50) NOT NULL,
  `patient_id` int(50) NOT NULL,
  PRIMARY KEY (`caretaker_id`,`patient_id`),
  KEY `patient_id` (`patient_id`),
  CONSTRAINT `caretakers_ibfk_1` FOREIGN KEY (`caretaker_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `caretakers_ibfk_2` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci

CREATE TABLE `vitals` (
  `blood_pressure_systolic` float NOT NULL,
  `blood_pressure_diastolic` float NOT NULL,
  `body_temperature` float NOT NULL,
  `device_id` int(11) NOT NULL,
  `pulse_rate` float NOT NULL,
  `oxygen_saturation` float NOT NULL,
  `vitals_id` int(11) NOT NULL AUTO_INCREMENT,
  `created_date` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`vitals_id`),
  KEY `device_id` (`device_id`),
  CONSTRAINT `vitals_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `patients` (`device_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci



blood pressure.

Low Blood Pressure:
Systolic: Less than 90 mmHg
Diastolic: Less than 60 mmHg
Normal Blood Pressure:
Systolic: Less than 120 mmHg
Diastolic: Less than 80 mmHg
Elevated Blood Pressure:
Systolic: 120-129 mmHg
Diastolic: Less than 80 mmHg
Stage 1 Hypertension:
Systolic: 130-139 mmHg
Diastolic: 80-89 mmHg
Stage 2 Hypertension:
Systolic: 140 mmHg or higher
Diastolic: 90 mmHg or higher
Hypertensive Crisis (Emergency):
Systolic: Higher than 180 mmHg
Diastolic: Higher than 120 mmHg
Body Temperature

Axillary (Armpit) Temperature:
Low: Below 35.9°C
Normal: 35.9°C to 36.9°C
Fever (low-grade): Above 36.9°C to 37.6°C
Fever (moderate): Above 37.6°C to 38.7°C
Fever (high): Above 38.7°C
Oxygen saturation ranges

Normal - 95% to 100%

Corcening - 91% to 95%

Low - <91%

Pulse Rate ranges

Resting Pulse Rate (Adults):
Normal: 60 to 100 beats per minute (bpm)
Children (age 1 to 17 years):
Normal: 70 to 100 bpm
Infants (up to 12 months):
Normal: 80 to 160 bpm
High Pulse Rate (Tachycardia):

Adults: above 100 bpm
Children: above 100 bpm
Infants: above 160 bpm
Low Pulse Rate (Bradycardia):

Adults: 60 bpm may be considered low.
Children: below 70 bpm.
Infants: below 80 bpm