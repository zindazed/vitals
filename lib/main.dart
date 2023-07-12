// import 'package:flutter/material.dart';
// // import 'screens/patients.dart';

// void main() {
//   runApp(const MyApp());
// }
import 'dart:convert';
// import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:vital_monitor/logic/models/userModel.dart';
import 'package:vital_monitor/screens/mainMenu.dart';
import 'package:vital_monitor/screens/monitoredPatients.dart';
import 'package:vital_monitor/screens/screenb.dart';
import 'logic/models/userProvider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => UserProvider(),
        child: MaterialApp(
          home: SignUpPage(),
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
        ));
  }
}

class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _passwordsMatch = true;

  @override
  Widget build(BuildContext context) {
    Future<void> signup() async {}

    return Scaffold(
      body: Container(
        color: const Color.fromRGBO(0, 33, 71, 1),
        child: ListView(
          children: [
            Image.asset(
              'assets/image_icon.png',
              width: 200, // Adjust the width as needed
              height: 200, // Adjust the height as needed
            ),
            Container(
              height: 350,
              margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
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
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child:
                                  // Text(dataList.first.device_id,
                                  //     style: TextStyle(color: Colors.green))
                                  TextField(
                                controller: _usernameController,
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
                                  hintText: 'Username',
                                  contentPadding: const EdgeInsets.all(10.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child:
                                  // Text(dataList.first.device_id,
                                  //     style: TextStyle(color: Colors.green))
                                  TextField(
                                onChanged: (value) {
                                  setState(() {
                                    _passwordsMatch = value ==
                                        _confirmPasswordController.text;
                                  });
                                },
                                obscureText: true,
                                controller: _passwordController,
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
                                  hintText: 'Password',
                                  contentPadding: const EdgeInsets.all(10.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child:
                                  // Text(dataList.first.device_id,
                                  //     style: TextStyle(color: Colors.green))
                                  TextField(
                                onChanged: (value) {
                                  setState(() {
                                    _passwordsMatch =
                                        value == _passwordController.text;
                                  });
                                },
                                obscureText: true,
                                controller: _confirmPasswordController,
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
                                  hintText: 'Confirm Password',
                                  errorText: _passwordsMatch
                                      ? null
                                      : 'Passwords do not match',
                                  contentPadding: const EdgeInsets.all(10.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(0, 33, 71,
                              1), // Set the button background color to green
                          side: BorderSide.none,
                        ),
                        onPressed: () async {
                          if (_passwordsMatch) {
                            if (_usernameController.text != "" &&
                                _passwordController.text != "") {
                              final url =
                                  'https://patientvitalsproject.000webhostapp.com/api2.php';
                              final response = await http.post(
                                Uri.parse(url),
                                body: {
                                  'signup': 'true',
                                  'username': _usernameController.text,
                                  'password': _passwordController.text,
                                },
                              );

                              final data = jsonDecode(response.body);
                              final success = data['success'] as bool;
                              final message = data['message'] as String;

                              if (success) {
                                //Access the UserProvider instance
                                UserProvider userProvider =
                                    Provider.of<UserProvider>(context,
                                        listen: false);

                                //set the logged-in user in the provider
                                userProvider.setUser(User(
                                    data['id'].toString(),
                                    _usernameController.text,
                                    _passwordController.text));

                                //Navigate to main menu
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MainMenu()),
                                );
                                // showDialog(
                                //   context: context,
                                //   builder: (context) => AlertDialog(
                                //     title: Text('Success'),
                                //     content: Text(message),
                                //     actions: [
                                //       TextButton(
                                //         onPressed: () =>
                                //             Navigator.of(context).pop(),
                                //         child: Text('OK'),
                                //       ),
                                //     ],
                                //   ),
                                // );
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
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Error'),
                                  content: Text("Fill the empty fields"),
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
                                  content: Text('Passwords do not match.'),
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
                        child: Container(
                            margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              color: const Color.fromRGBO(255, 255, 255, 0.2),
                            ),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            )),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to sign-up screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                        child: Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            padding: const EdgeInsets.all(5),
                            child: const Text(
                              "Already have an account, Go to login",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            )),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Future<void> login() async {}

    return Scaffold(
      body: Container(
        color: const Color.fromRGBO(0, 33, 71, 1),
        child: ListView(
          children: [
            Image.asset(
              'assets/image_icon.png',
              width: 200, // Adjust the width as needed
              height: 200, // Adjust the height as needed
            ),
            Container(
              height: 350,
              margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
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
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child:
                                  // Text(dataList.first.device_id,
                                  //     style: TextStyle(color: Colors.green))
                                  TextField(
                                controller: _usernameController,
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
                                  hintText: 'Username',
                                  contentPadding: const EdgeInsets.all(10.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child:
                                  // Text(dataList.first.device_id,
                                  //     style: TextStyle(color: Colors.green))
                                  TextField(
                                obscureText: true,
                                controller: _passwordController,
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
                                  hintText: 'Password',
                                  contentPadding: const EdgeInsets.all(10.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(0, 33, 71,
                              1), // Set the button background color to green
                          side: BorderSide.none,
                        ),
                        onPressed: () async {
                          if (_usernameController.text != "" &&
                              _passwordController.text != "") {
                            final url =
                                'https://patientvitalsproject.000webhostapp.com/api2.php';
                            final response = await http.post(
                              Uri.parse(url),
                              body: {
                                'login': 'true',
                                'username': _usernameController.text,
                                'password': _passwordController.text,
                              },
                            );

                            final data = jsonDecode(response.body);
                            final success = data['success'] as bool;
                            final message = data['message'] as String;

                            if (success) {
                              //Access the UserProvider instance
                              UserProvider userProvider =
                                  Provider.of<UserProvider>(context,
                                      listen: false);

                              //set the logged-in user in the provider
                              userProvider.setUser(User(
                                  data['id'].toString(),
                                  _usernameController.text,
                                  _passwordController.text));

                              _usernameController.text = "";
                              _passwordController.text = "";
                              //Navigate to main menu
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MainMenu()),
                              );
                              // showDialog(
                              //   context: context,
                              //   builder: (context) => AlertDialog(
                              //     title: Text('Success'),
                              //     content: Text(message),
                              //     actions: [
                              //       TextButton(
                              //         onPressed: () =>
                              //             Navigator.of(context).pop(),
                              //         child: Text('OK'),
                              //       ),
                              //     ],
                              //   ),
                              // );
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
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Error'),
                                content: Text("Fill the empty fields"),
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
                        },
                        child: Container(
                            margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              color: const Color.fromRGBO(255, 255, 255, 0.2),
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            )),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to sign-up screen
                          Navigator.pop(context);
                        },
                        child: Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            padding: const EdgeInsets.all(5),
                            child: const Text(
                              "Back to sign up",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            )),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
