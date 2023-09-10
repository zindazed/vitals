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
// import 'package:mysql1/mysql1.dart';

// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'global.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CareTakers extends StatefulWidget {
  String? userId;
  CareTakers(this.userId);
  @override
  _CareTakersState createState() => _CareTakersState(userId);
}

class _CareTakersState extends State<CareTakers> {
  _CareTakersState(this.userId);
  String? userId;

  List<MyPatients> patientsList = [];
  List<MyCareTakers> caretakersList = [];
  List<User> usersList = [];

  @override
  void initState() {
    super.initState();
    // Timer(const Duration(seconds: 3), () {
    fetchData2();
    // }); // Call the fetchData method to retrieve the data
  }

  Future<List<MyPatients>> fetchdevice() async {
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

  Future<List<MyCareTakers>> fetchData() async {
    final url = '$host/caretakers.php';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'patient_id': userId,
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return List<MyCareTakers>.from(
          jsonData.map((data) => MyCareTakers.fromJson(data)));
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
      List<MyPatients> fetchedDevice = await fetchdevice();
      List<MyCareTakers> fetchedData =
          await fetchData(); // Call the fetchData method that retrieves data
      List<User> fetchedUsersData = await fetchUsersData();
      setState(() {
        patientsList = fetchedDevice;
        caretakersList = fetchedData;
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
                      height: MediaQuery.of(context).size.height * 0.4,
                      margin: const EdgeInsets.fromLTRB(10, 20, 10, 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                      child: (caretakersList.isEmpty)
                          ? Center(
                              child: SpinKitFadingCube(
                              color: Colors.white,
                              size: 50.0,
                            ))
                          : Center(
                              // Center is a layout widget. It takes a single child and positions it
                              // in the middle of the parent.

                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: caretakersList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  MyCareTakers data = caretakersList[index];
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
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(""),
                                              Text(
                                                  usersList
                                                      .firstWhere((thisUser) =>
                                                          thisUser.user_id ==
                                                          data.caretakerId)
                                                      .username!,
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.white)),
                                              (data.caretakerId == user.user_id)
                                                  ? Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                      ),
                                                      child: IconButton(
                                                        iconSize: 20,
                                                        icon: Icon(
                                                          Icons.close_sharp,
                                                          color: Color.fromRGBO(
                                                              0, 33, 71, 1),
                                                          size: 29,
                                                        ),
                                                        onPressed: () {
                                                          // Define your custom action here
                                                          print(
                                                              'Close pressed!');
                                                        },
                                                      ),
                                                    )
                                                  : Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                      ),
                                                      child: IconButton(
                                                          iconSize: 20,
                                                          icon: Icon(
                                                            Icons.close_sharp,
                                                            color:
                                                                Color.fromRGBO(
                                                                    0,
                                                                    33,
                                                                    71,
                                                                    1),
                                                            size: 29,
                                                          ),
                                                          onPressed: () async {
                                                            // Show a confirmation dialog to the user
                                                            bool confirmed =
                                                                await showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      'Confirmation'),
                                                                  content: Text(
                                                                      'Are you sure you want to delete this caretaker?'),
                                                                  actions: <
                                                                      Widget>[
                                                                    TextButton(
                                                                      child: Text(
                                                                          'Cancel'),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop(false); // Return false when cancel button is pressed
                                                                      },
                                                                    ),
                                                                    TextButton(
                                                                      child: Text(
                                                                          'Delete'),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop(true); // Return true when delete button is pressed
                                                                      },
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );

                                                            if (confirmed ==
                                                                true) {
                                                              final url =
                                                                  '$host/caretakersDelete.php';
                                                              final response =
                                                                  await http
                                                                      .post(
                                                                Uri.parse(url),
                                                                body: {
                                                                  'caretaker_id':
                                                                      data.caretakerId
                                                                },
                                                              );

                                                              if (response
                                                                      .statusCode ==
                                                                  200) {
                                                                // Deletion successful
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                          'Success'),
                                                                      content: Text(
                                                                          'Caretaker deleted successfully.'),
                                                                      actions: <
                                                                          Widget>[
                                                                        TextButton(
                                                                          child:
                                                                              Text('OK'),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                );
                                                              } else {
                                                                // Error occurred during deletion
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                          'Error'),
                                                                      content: Text(
                                                                          'Failed to delete caretaker.'),
                                                                      actions: <
                                                                          Widget>[
                                                                        TextButton(
                                                                          child:
                                                                              Text('OK'),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                );
                                                              }
                                                            }
                                                          }),
                                                    )
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
                              child: Text("Care Takers",
                                  style: TextStyle(fontSize: 20))),
                        ),
                      ),
                    ),
                  ]),
                  Container(
                    margin: const EdgeInsets.fromLTRB(30, 5, 30, 5),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: patientsList.length,
                        itemBuilder: (BuildContext context, int index) {
                          MyPatients data = patientsList[index];
                          return Container(
                            margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 90,
                                      child: Text("Device id: ",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15)),
                                    ),
                                    Expanded(
                                        child: Text(data.device_id,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15))),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 90,
                                      child: Text("Device code: ",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15)),
                                    ),
                                    Expanded(
                                        child: Text(data.secret_code,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15))),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
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
