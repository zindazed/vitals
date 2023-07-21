import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vital_monitor/logic/models/mysql.dart';
import 'package:vital_monitor/main.dart';
import 'package:vital_monitor/screens/careTakers.dart';
import 'package:vital_monitor/screens/deviceMgt.dart';
import 'package:vital_monitor/screens/monitoredPatients.dart';
import 'screenb.dart';
import 'package:vital_monitor/logic/models/userModel.dart';
import 'package:vital_monitor/logic/models/userProvider.dart';
import 'global.dart';
// import 'package:mysql1/mysql1.dart';

// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vital Monitor',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.indigo,
      ),
      home: MainMenu(),
    );
  }
}

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  void initState() {
    super.initState();
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

          if (user == User(null, null, null)) {
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
                  Image.asset(
                    'assets/image_icon.png',
                    width: 200, // Adjust the width as needed
                    height: 200, // Adjust the height as needed
                  ),
                  Stack(children: [
                    Container(
                      height: 430,
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

                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              OutlinedButton(
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
                                            CareTakers(user?.user_id)),
                                  );
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    color: const Color.fromRGBO(
                                        255, 255, 255, 0.2),
                                    border: Border.all(
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Your Caretakers",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              OutlinedButton(
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
                                            MonitoredPatients(user?.user_id)),
                                  );
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    color: const Color.fromRGBO(
                                        255, 255, 255, 0.2),
                                    border: Border.all(
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Your Patients",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              OutlinedButton(
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
                                            DeviceMgt(user?.user_id)),
                                  );
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    color: const Color.fromRGBO(
                                        255, 255, 255, 0.2),
                                    border: Border.all(
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Your Device",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              OutlinedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(
                                      0,
                                      33,
                                      71,
                                      1), // Set the button background color to green
                                  side: BorderSide.none,
                                ),
                                onPressed: () {
                                  // Access the UserProvider instance to logout
                                  UserProvider userProvider =
                                      Provider.of<UserProvider>(context,
                                          listen: false);
                                  userProvider.logout();

                                  // Navigate back to the login screen
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    color: Color.fromARGB(210, 218, 2, 2),
                                    border: Border.all(
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Logout",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: const Color.fromRGBO(
                                                0, 33, 71, 1)),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
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
                              child: Text("Main Menu",
                                  style: TextStyle(fontSize: 20))),
                        ),
                      ),
                    ),
                  ]),
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
