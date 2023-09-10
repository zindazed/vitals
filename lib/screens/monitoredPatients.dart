import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vital_monitor/logic/models/mysql.dart';
import 'package:vital_monitor/main.dart';
import 'package:vital_monitor/screens/patientDetails.dart';
import 'screenb.dart';
import 'package:vital_monitor/logic/models/userModel.dart';
import 'package:vital_monitor/logic/models/userProvider.dart';
import 'global.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:mysql1/mysql1.dart';

// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MonitoredPatients extends StatefulWidget {
  String? userId;
  MonitoredPatients(this.userId);
  @override
  _MonitoredPatientsState createState() => _MonitoredPatientsState(userId);
}

class _MonitoredPatientsState extends State<MonitoredPatients> {
  _MonitoredPatientsState(this.userId);
  String? userId;
  List<MyData> dataList = [];
  List<MyPatients> patientsList = [];
  List<User> usersList = [];
  late Timer? _timer;

  final TextEditingController _deviceId = TextEditingController();
  final TextEditingController _deviceCode = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData3().then((value) => startTimer());
  }

  void startTimer() async {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) async {
      fetchData2();
    });
  }

  Future<List<MyData>> fetchData() async {
    final url = '$host/api.php';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'caretaker_id': userId,
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return List<MyData>.from(jsonData.map((data) => MyData.fromJson(data)));
    } else {
      throw Exception('Failed to retrieve data');
    }
  }

  Future<List<MyPatients>> fetchPatientsData() async {
    final response = await http.get(Uri.parse('$host/monitoredPatients.php'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return List<MyPatients>.from(
          jsonData.map((data) => MyPatients.fromJson(data)));
    } else {
      throw Exception('Failed to retrieve data');
    }
  }

  Future<List<User>> fetchUsersData() async {
    final response = await http.get(Uri.parse('$host/users.php'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return List<User>.from(jsonData.map((data) => User.fromJson(data)));
    } else {
      throw Exception('Failed to retrieve data');
    }
  }

  Future<void> fetchData2() async {
    try {
      List<MyData> fetchedData =
          await fetchData(); // Call the fetchData method that retrieves data
      if (mounted) {
        setState(() {
          dataList = fetchedData;
        });
      }
    } catch (e) {
      // Handle error cases
      print('Error: $e');
    }
  }

  Future<void> fetchData3() async {
    try {
      List<MyData> fetchedData = await fetchData();
      List<MyPatients> fetchedPatientsData = await fetchPatientsData();
      List<User> fetchedUsersData = await fetchUsersData();
      if (mounted) {
        setState(() {
          dataList = fetchedData;
          patientsList = fetchedPatientsData;
          usersList = fetchedUsersData;
        });
      }
    } catch (e) {
      // Handle error cases
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          User? user = userProvider.user;

          if (user == null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
            return const Text("Logged out");
          } else {
            return Container(
              color: const Color.fromRGBO(0, 33, 71, 1),
              child: ListView(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        color: Colors.white,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  Image.asset(
                    'assets/image_icon.png',
                    width: 200, // Adjust the width as needed
                    height: 200, // Adjust the height as needed
                  ),
                  InformationIconPopup(),
                  Stack(children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      margin: const EdgeInsets.fromLTRB(10, 20, 10, 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                      child: Center(
                        // Center is a layout widget. It takes a single child and positions it
                        // in the middle of the parent.

                        child: (dataList.isEmpty)
                            ? Center(
                                child: SpinKitFadingCube(
                                color: Colors.white,
                                size: 50.0,
                              ))
                            : SingleChildScrollView(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: dataList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    MyData data = dataList[index];
                                    return OutlinedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromRGBO(
                                            0,
                                            33,
                                            71,
                                            1), // Set the button background color to green
                                        side: BorderSide.none,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PatientDetails(
                                                    data: data,
                                                    user: usersList.firstWhere(
                                                      (user) =>
                                                          user.user_id ==
                                                          patientsList
                                                              .firstWhere(
                                                                (patient) =>
                                                                    patient
                                                                        .device_id ==
                                                                    data.device_id,
                                                              )
                                                              .patient_id,
                                                    ),
                                                    patient:
                                                        patientsList.firstWhere(
                                                      (patient) =>
                                                          patient.device_id ==
                                                          data.device_id,
                                                    ),
                                                  )),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            10, 5, 10, 5),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          color: const Color.fromRGBO(
                                              255, 255, 255, 0.2),
                                          border: Border.all(
                                            width: 2.0,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                                usersList
                                                    .firstWhere(
                                                      (user) =>
                                                          user.user_id ==
                                                          patientsList
                                                              .firstWhere(
                                                                (patient) =>
                                                                    patient
                                                                        .device_id ==
                                                                    data.device_id,
                                                              )
                                                              .patient_id,
                                                    )
                                                    .username!,
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white)),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              // Column is also a layout widget. It takes a list of children and
                                              // arranges them vertically. By default, it sizes itself to fit its
                                              // children horizontally, and tries to be as tall as its parent.
                                              //
                                              // Invoke "debug painting" (press "p" in the console, choose the
                                              // "Toggle Debug Paint" action from the Flutter Inspector in Android
                                              // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
                                              // to see the wireframe for each widget.
                                              //
                                              // Column has various properties to control how it sizes itself and
                                              // how it positions its children. Here we use mainAxisAlignment to
                                              // center the children vertically; the main axis here is the vertical
                                              // axis because Columns are vertical (the cross axis would be
                                              // horizontal).
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'BP:',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        Text(
                                                          "${data.blood_pressure_systolic} ${data.blood_pressure_diastolic}",
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              color: double.parse(data
                                                                              .blood_pressure_systolic) <
                                                                          90 &&
                                                                      double.parse(data
                                                                              .blood_pressure_diastolic) <
                                                                          60
                                                                  ? Colors.blue
                                                                  : double.parse(data.blood_pressure_systolic) <
                                                                              120 ||
                                                                          double.parse(data.blood_pressure_diastolic) <
                                                                              80
                                                                      ? Colors
                                                                          .green
                                                                      : double.parse(data.blood_pressure_systolic) < 130 &&
                                                                              double.parse(data.blood_pressure_diastolic) <
                                                                                  80
                                                                          ? Colors
                                                                              .yellow
                                                                          : double.parse(data.blood_pressure_systolic) < 140 || double.parse(data.blood_pressure_diastolic) < 90
                                                                              ? Colors.orange
                                                                              : Colors.red),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'PR:',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        Text(
                                                          data.pulse_rate,
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              color: double.parse(data.pulse_rate) <
                                                                              80 &&
                                                                          (DateTime.parse(patientsList
                                                                                              .firstWhere(
                                                                                                (patient) => patient.device_id == data.device_id,
                                                                                              )
                                                                                              .dob)
                                                                                          .difference(DateTime.now())
                                                                                          .inDays /
                                                                                      365)
                                                                                  .floor() <
                                                                              1 ||
                                                                      double.parse(data.pulse_rate) < 70 &&
                                                                          (DateTime.parse(patientsList
                                                                                              .firstWhere(
                                                                                                (patient) => patient.device_id == data.device_id,
                                                                                              )
                                                                                              .dob)
                                                                                          .difference(DateTime.now())
                                                                                          .inDays /
                                                                                      365)
                                                                                  .floor() <
                                                                              18 ||
                                                                      double.parse(data.pulse_rate) < 60 &&
                                                                          (DateTime.parse(patientsList
                                                                                              .firstWhere(
                                                                                                (patient) => patient.device_id == data.device_id,
                                                                                              )
                                                                                              .dob)
                                                                                          .difference(DateTime.now())
                                                                                          .inDays /
                                                                                      365)
                                                                                  .floor() >=
                                                                              18
                                                                  ? Colors.blue
                                                                  : double.parse(data.pulse_rate) > 160 &&
                                                                              (DateTime.parse(patientsList
                                                                                                  .firstWhere(
                                                                                                    (patient) => patient.device_id == data.device_id,
                                                                                                  )
                                                                                                  .dob)
                                                                                              .difference(DateTime.now())
                                                                                              .inDays /
                                                                                          365)
                                                                                      .floor() <
                                                                                  1 ||
                                                                          double.parse(data.pulse_rate) > 100 &&
                                                                              (DateTime.parse(patientsList
                                                                                                  .firstWhere(
                                                                                                    (patient) => patient.device_id == data.device_id,
                                                                                                  )
                                                                                                  .dob)
                                                                                              .difference(DateTime.now())
                                                                                              .inDays /
                                                                                          365)
                                                                                      .floor() >
                                                                                  1
                                                                      ? Colors.red
                                                                      : Colors.green),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'O2:',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        Text(
                                                          data.oxygen_saturation,
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              color: double.parse(data
                                                                          .oxygen_saturation) <
                                                                      91
                                                                  ? Colors.red
                                                                  : double.parse(data
                                                                              .oxygen_saturation) <
                                                                          96
                                                                      ? Colors
                                                                          .yellow
                                                                      : Colors
                                                                          .green),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'T:',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        Text(
                                                          data.body_temperature,
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              color: double.parse(data
                                                                          .body_temperature) <
                                                                      35.9
                                                                  ? Colors.blue
                                                                  : double.parse(data
                                                                              .body_temperature) <
                                                                          37.2
                                                                      ? Colors
                                                                          .green
                                                                      : double.parse(data.body_temperature) <
                                                                              38.7
                                                                          ? Colors
                                                                              .orange
                                                                          : Colors
                                                                              .red),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      top: -2, // Adjust the top position to control the overlap
                      left: 10, // Adjust the left position as needed
                      right: 10,
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                            color: const Color.fromRGBO(255, 255, 255, 1),
                            border: Border.all(
                              width: 2.0,
                            ),
                          ),
                          child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text("Monitored Patients",
                                  style: TextStyle(fontSize: 20))),
                        ),
                      ),
                    ),
                  ]),
                  Container(
                    height: 150,
                    margin: const EdgeInsets.fromLTRB(30, 20, 30, 5),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 90,
                              child: Text("Device id: ",
                                  style: TextStyle(color: Colors.white)),
                            ),
                            Expanded(
                              child:
                                  // Text(dataList.first.device_id,
                                  //     style: TextStyle(color: Colors.green))
                                  TextField(
                                controller: _deviceId,
                                style: const TextStyle(
                                    color: Colors.black), // Set the text color
                                decoration: InputDecoration(
                                  filled: true, // Set filled to true
                                  fillColor: Colors
                                      .white, // Set the background color of the text input
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide:
                                        BorderSide.none, // Remove the border
                                  ),
                                  hintText: 'Enter text',
                                  contentPadding: const EdgeInsets.all(10.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 90,
                              child: Text("Device code: ",
                                  style: TextStyle(color: Colors.white)),
                            ),
                            Expanded(
                              child:
                                  // Text(dataList.first.device_id,
                                  //     style: TextStyle(color: Colors.green))
                                  TextField(
                                controller: _deviceCode,
                                style: const TextStyle(
                                    color: Colors.black), // Set the text color
                                decoration: InputDecoration(
                                  filled: true, // Set filled to true
                                  fillColor: Colors
                                      .white, // Set the background color of the text input
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide:
                                        BorderSide.none, // Remove the border
                                  ),
                                  hintText: 'Enter text',
                                  contentPadding: const EdgeInsets.all(10.0),
                                ),
                              ),
                            ),
                            Container(
                              width: 50,
                              margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                              color: const Color.fromRGBO(255, 255, 255, 0),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors
                                        .green, // Set the button background color to green
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10.0), // Set the border radius
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                  ),
                                  onPressed: () async {
                                    if (_deviceId.text != "" &&
                                        _deviceCode.text != "") {
                                      final url = '$host/attachdevice.php';
                                      final response = await http.post(
                                        Uri.parse(url),
                                        body: {
                                          'monitor': 'true',
                                          'deviceId': _deviceId.text,
                                          'deviceCode': _deviceCode.text,
                                          'caretaker_id': user.user_id,
                                        },
                                      );

                                      final data = jsonDecode(response.body);
                                      final success = data['success'] as bool;
                                      final message = data['message'] as String;

                                      if (success) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(
                                                'Successfully added patient on your monitor list'),
                                            content: Text(message),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('Error'),
                                            content: Text(message),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    } else {
                                      // Passwords do not match, display an error message
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Error'),
                                            content: Text(
                                                'Empty fields need filling'),
                                            actions: [
                                              TextButton(
                                                child: Text('OK'),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: const Icon(Icons.check,
                                      color: Color.fromRGBO(0, 33, 71, 1),
                                      size: 35.0)),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
            // Column(
            //   children: [
            //     Text('Logged-in User'),
            //     Text('Username: ${user.username}'),
            //     ElevatedButton(
            //       onPressed: () {
            //         // Access the UserProvider instance to logout
            //         UserProvider userProvider =
            //             Provider.of<UserProvider>(context, listen: false);
            //         userProvider.logout();

            //         // Navigate back to the login screen
            //         Navigator.pop(context);
            //       },
            //       child: Text('Logout'),
            //     ),
            //   ],
            // );
          }
        },
      ),
    );
  }
}

class InformationIconPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Blood Pressure (BP)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildInfoTile(
                        'Low Blood Pressure (colored with blue)',
                        'Systolic: Less than 90 mmHg\n'
                            'Diastolic: Less than 60 mmHg',
                        Colors.blue,
                      ),
                      _buildInfoTile(
                        'Normal Blood Pressure (colored with green):',
                        'Systolic: Less than 120 mmHg\n'
                            'Diastolic: Less than 80 mmHg',
                        Colors.green,
                      ),
                      _buildInfoTile(
                        'Elevated Blood Pressure (colored with yellow):',
                        'Systolic: 120-129 mmHg\n'
                            'Diastolic: Less than 80 mmHg',
                        Colors.yellow,
                      ),
                      _buildInfoTile(
                        'Stage 1 Hypertension (colored with orange):',
                        'Systolic: 130-139 mmHg\n'
                            'Diastolic: 80-89 mmHg',
                        Colors.orange,
                      ),
                      _buildInfoTile(
                        'Stage 2 Hypertension (colored with red):',
                        'Systolic: 140 mmHg or higher\n'
                            'Diastolic: 90 mmHg or higher',
                        Colors.red,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Temperature (T)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildInfoTile(
                        'Low: ',
                        'Below 35.9°C (colored with blue)',
                        Colors.blue,
                      ),
                      _buildInfoTile(
                        'Normal: ',
                        '35.9°C to 36.9°C (colored with green)',
                        Colors.green,
                      ),
                      _buildInfoTile(
                        'Fever (moderate): ',
                        'Above 37.6°C to 38.7°C (colored with orange)',
                        Colors.orange,
                      ),
                      _buildInfoTile(
                        'Fever (high): ',
                        'Above 38.7°C (colored with red)',
                        Colors.red,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Oxygen Saturation (O2)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildInfoTile(
                        'Normal:',
                        '95% to 100% (colored with green)',
                        Colors.green,
                      ),
                      _buildInfoTile(
                        'Concerning:',
                        '91% to 95% (colored with yellow)',
                        Colors.yellow,
                      ),
                      _buildInfoTile(
                        'Low:',
                        'Less than 91% (colored with red)',
                        Colors.red,
                      ),
                      SizedBox(height: 16),
                      SizedBox(height: 16),
                      Text(
                        'Pulse Rate (PR)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildInfoTile(
                        'Normal Pulse Rate (colored with green):',
                        'Resting Pulse Rate (Adults):\n'
                            'Normal: 60 to 100 bpm\n'
                            'Children (age 1 to 17 years):\n'
                            'Normal: 70 to 100 bpm\n'
                            'Infants (up to 12 months):\n'
                            'Normal: 80 to 160 bpm',
                        Colors.green,
                      ),
                      _buildInfoTile(
                        'High Pulse Rate (Tachycardia) (colored with red):',
                        'Adults: above 100 bpm\n'
                            'Children: above 100 bpm\n'
                            'Infants: above 160 bpm',
                        Colors.red,
                      ),
                      _buildInfoTile(
                        'Low Pulse Rate (Bradycardia) (colored with blue):',
                        'Adults: 60 bpm may be considered low\n'
                            'Children: below 70 bpm\n'
                            'Infants: below 80 bpm',
                        Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.info,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String description, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            color: color,
          ),
        ),
        Divider(),
        SizedBox(height: 8),
      ],
    );
  }
}
