import 'dart:async';
import 'dart:ffi';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vital_monitor/logic/models/mysql.dart';
import 'package:vital_monitor/main.dart';
import 'package:vital_monitor/screens/patientDetails.dart';
import 'screenb.dart';
import 'package:vital_monitor/logic/models/userModel.dart';
import 'package:vital_monitor/logic/models/userProvider.dart';
// import 'package:mysql1/mysql1.dart';

// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'global.dart';

class DeviceMgt extends StatefulWidget {
  String? userId;
  DeviceMgt(this.userId);
  @override
  _DeviceMgtState createState() => _DeviceMgtState(userId);
}

class _DeviceMgtState extends State<DeviceMgt> {
  _DeviceMgtState(this.userId);
  String? userId;
  List<MyPatients> patientsList = [];
  List<User> usersList = [];
  DateTime? _selectedDate;

  final TextEditingController _deviceId = TextEditingController();
  final TextEditingController _deviceCode = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
    fetchData2();
    // }); // Call the fetchData method to retrieve the data
  }

  Future<List<MyPatients>> fetchData() async {
    final url = '$host/device.php';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'patient_id': userId,
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return List<MyPatients>.from(
          jsonData.map((data) => MyPatients.fromJson(data)));
    } else {
      throw Exception('Failed to retrieve data');
    }
  }

  Future<List<User>> fetchUsersData() async {
    final response = await http.get(Uri.parse('$host/userscaretakers.php'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return List<User>.from(jsonData.map((data) => User.fromJson(data)));
    } else {
      throw Exception('Failed to retrieve data');
    }
  }

  Future<void> fetchData2() async {
    try {
      List<MyPatients> fetchedData =
          await fetchData(); // Call the fetchData method that retrieves data
      List<User> fetchedUsersData = await fetchUsersData();
      setState(() {
        patientsList = fetchedData;
        usersList = fetchedUsersData;
      });
    } catch (e) {
      // Handle error cases
      print('Error: $e');
    }
  }

  @override
  void dispose() {
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
                  Stack(children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.2,
                      margin: const EdgeInsets.fromLTRB(10, 20, 10, 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                      child: (patientsList.isEmpty)
                          ? Center(child: CircularProgressIndicator())
                          : Center(
                              // Center is a layout widget. It takes a single child and positions it
                              // in the middle of the parent.

                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: patientsList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  MyPatients data = patientsList[index];
                                  return OutlinedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(
                                          0,
                                          33,
                                          71,
                                          1), // Set the button background color to green
                                      side: BorderSide.none,
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          10, 10, 10, 10),
                                      padding: const EdgeInsets.all(20),
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
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(data.device_id,
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white)),
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
                              child: Text("Device Management",
                                  style: TextStyle(fontSize: 20))),
                        ),
                      ),
                    ),
                  ]),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => _selectDate(context),
                        child: Text(
                          'Select Date of Birth',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        _selectedDate != null
                            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                            : 'No date selected',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 150,
                    margin: const EdgeInsets.fromLTRB(30, 20, 30, 5),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 90,
                              child: Text("Device id: ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 17)),
                            ),
                            Expanded(
                              child:
                                  // Text(dataList.first.device_id,
                                  //     style: TextStyle(color: Colors.green))
                                  TextField(
                                controller: _deviceId,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15), // Set the text color
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
                            SizedBox(
                              width: 90,
                              child: Text("Device code: ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15)),
                            ),
                            Expanded(
                              child:
                                  // Text(dataList.first.device_id,
                                  //     style: TextStyle(color: Colors.green))
                                  TextField(
                                controller: _deviceCode,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15), // Set the text color
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
                                    if (_selectedDate != null &&
                                        _deviceId.text != "" &&
                                        _deviceCode.text != "") {
                                      final url = '$host/attachdevice.php';
                                      final response = await http.post(
                                        Uri.parse(url),
                                        body: {
                                          'attach': 'true',
                                          'dob': DateFormat('yyyy-MM-dd')
                                              .format(_selectedDate!),
                                          'deviceId': _deviceId.text,
                                          'deviceCode': _deviceCode.text,
                                          'patientId': user.user_id,
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
                                                'Successfully attached device'),
                                            content: Text(message),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: Text('OK'),
                                              ),
                                            ],
                                          ),
                                        ).then((value) => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DeviceMgt(user.user_id)),
                                            ));
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
