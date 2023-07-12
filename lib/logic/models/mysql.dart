// import 'package:mysql1/mysql1.dart';

// class Mysql {
//   static String host = 'sql12.freemysqlhosting.net',
//       user = 'sql12605501',
//       password = '6s3YJeq6ZN',
//       db = 'sql12605501';
//   static int port = 3306;

//   Mysql();

//   Future<MySqlConnection> getConnection() async {
//     var settings = ConnectionSettings(
//         host: host, port: port, user: user, password: password, db: db);
//     return await MySqlConnection.connect(settings);
//   }
// }

class MyData {
  final String blood_pressure_systolic;
  final String blood_pressure_diastolic;
  final String body_temperature;
  final String device_id;
  final String pulse_rate;
  final String oxygen_saturation;
  final String vitals_id;
  final String created_date;

  MyData(
      {required this.blood_pressure_systolic,
      required this.blood_pressure_diastolic,
      required this.body_temperature,
      required this.device_id,
      required this.pulse_rate,
      required this.oxygen_saturation,
      required this.vitals_id,
      required this.created_date});

  factory MyData.fromJson(Map<String, dynamic> json) {
    return MyData(
      blood_pressure_systolic: json['sP'],
      blood_pressure_diastolic: json['dP'],
      body_temperature: json['bT'],
      device_id: json['di'],
      pulse_rate: json['hP'],
      oxygen_saturation: json['oS'],
      vitals_id: json['id'],
      created_date: json['created_date'],
    );
  }

  String getVital(vital) {
    if (vital == 'Systolic Blood Pressure') {
      return blood_pressure_systolic;
    } else if (vital == 'Diastolic Blood Pressure') {
      return blood_pressure_diastolic;
    } else if (vital == 'Temperature') {
      return body_temperature;
    } else if (vital == 'Pulse Rate') {
      return pulse_rate;
    } else if (vital == 'Oxygen Saturation') {
      return oxygen_saturation;
    } else {
      return "";
    }
  }
}

class MyPatients {
  final String dob;
  final String device_id;
  final String patient_id;
  final String secret_code;

  MyPatients({
    required this.dob,
    required this.device_id,
    required this.patient_id,
    required this.secret_code,
  });

  factory MyPatients.fromJson(Map<String, dynamic> json) {
    return MyPatients(
      dob: json['dob'],
      device_id: json['device_id'],
      patient_id: json['patient_id'],
      secret_code: json['secret_code'],
    );
  }
}

class MyCareTakers {
  final String patientId;
  final String caretakerId;

  MyCareTakers({
    required this.patientId,
    required this.caretakerId,
  });

  factory MyCareTakers.fromJson(Map<String, dynamic> json) {
    return MyCareTakers(
      patientId: json['patient_id'],
      caretakerId: json['caretaker_id'],
    );
  }
}
