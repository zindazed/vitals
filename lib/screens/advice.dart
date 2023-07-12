import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vital_monitor/logic/models/mysql.dart';
import 'package:vital_monitor/main.dart';
import 'screenb.dart';
import 'package:vital_monitor/logic/models/userModel.dart';
import 'package:vital_monitor/logic/models/userProvider.dart';
// import 'package:mysql1/mysql1.dart';

// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Advice extends StatefulWidget {
  final MyData data;
  final MyPatients gotpatient;
  const Advice({Key? key, required this.data, required this.gotpatient})
      : super(key: key);

  @override
  _AdviceState createState() => _AdviceState(data, gotpatient);
}

class _AdviceState extends State<Advice> {
  final MyData data;
  final MyPatients gotpatient;
  _AdviceState(this.data, this.gotpatient);

  List<String> lowPressure = [
    "Help the Person Lie Down: If the person is feeling dizzy, lightheaded, or faint, help them lie down on their back. Elevate their legs slightly, which can help improve blood flow to the brain.",
    "Encourage Fluid Intake: If the person is conscious and able to swallow, offer them water or a sports drink with electrolytes. Dehydration can contribute to low blood pressure, and fluid intake may help improve blood volume",
    "Assess for Signs of Shock: In severe cases of low blood pressure, the person may be at risk of going into shock. Signs of shock include rapid breathing, weak or rapid pulse, pale or bluish skin, and confusion. If shock is suspected, seek emergency medical help immediately.",
    "Seek Medical Attention: If the person's symptoms do not improve or worsen, if they have a history of heart problems, or if they are on medication that may affect blood pressure, it is crucial to seek medical attention promptly.",
  ];

  List<String> elevatedPressure = [
    'If the elevated blood pressure reading is an isolated incident without any symptoms, it is advisable to monitor the blood pressure regularly and consult a healthcare professional for further evaluation.',
    'Drinking water can help dilute your blood and temporarily lower blood pressure. Aim to stay adequately hydrated throughout the day',
  ];

  List<String> stage1Hypertension = [
    'If symptoms such as severe headache, chest pain, shortness of breath, or dizziness are present, it is important to seek medical attention immediately.',
    'If the person is not experiencing any symptoms, it is essential to encourage lifestyle modifications such as regular exercise, healthy eating, reducing sodium intake, managing stress, and maintaining a healthy weight.',
  ];

  List<String> stage2Hypertension = [
    "In cases of stage 2 hypertension like this one, it is crucial to seek immediate medical attention, especially if symptoms such as severe headache, chest pain, shortness of breath, or dizziness are present.",
    "While waiting for medical help, it may be helpful to keep the person calm and ensure they are in a comfortable position.",
  ];

  List<String> fever = [
    "Encourage rest and provide a comfortable environment.",
    "Offer fluids to maintain hydration.",
    "Remove excess clothing or blankets to help cool the person down.",
    "Apply cool compresses to the forehead, neck, and armpits to help lower body temperature.",
    "Monitor the person's symptoms closely. If the fever persists, worsens, or is accompanied by severe symptoms, seek medical attention promptly.",
  ];

  List<String> lowTemp = [
    "Call for Emergency Assistance: If you encounter someone with a low body temperature, call for emergency medical help immediately. Hypothermia is a medical emergency, and professional medical attention is needed.",
    "Move to a Warm Environment: If it is safe to do so, move the person to a warm and sheltered area away from cold and wet conditions. Protect them from further exposure to cold temperatures.",
    "Insulate and Cover: Insulate the person from the cold ground by placing a thick layer of blankets or a sleeping bag underneath them. Cover the person's head, neck, and extremities with additional blankets or clothing to help retain heat.",
    "Provide Warmth: Use external heat sources to warm the person. Apply heating pads or warm water bottles wrapped in cloth to areas such as the armpits, groin, and neck. Be careful to avoid direct contact with the skin and check the temperature of the heat source to prevent burns.",
    "Monitor Breathing and Pulse: Continuously monitor the person's breathing and pulse. If they are unresponsive or not breathing, begin CPR if you are trained to do so.",
  ];

  List<String> highPulseRate = [
    "Assess the Person: If the person is experiencing a high pulse rate but is conscious and not showing severe symptoms, start by assessing their overall condition. If they have a known heart condition or are experiencing significant distress, seek immediate medical assistance.",
    "Encourage Calmness: Help the person relax and sit or lie down in a comfortable position to reduce stress and anxiety.",
    "Provide Comfort: Offer reassurance and support to the person. Encourage them to take slow, deep breaths and practice relaxation techniques to help lower their heart rate.",
    "Monitor the Person: Keep an eye on the person's pulse rate, and if possible, check their blood pressure. Monitor their condition for any changes or worsening symptoms.",
    "Seek Medical Assistance: If the high pulse rate persists, is accompanied by severe symptoms (e.g., chest pain, shortness of breath, dizziness, fainting), or if the person has a known heart condition, call for emergency medical assistance",
  ];

  List<String> lowPulseRate = [
    "Monitor Vital Signs: Check the person's pulse, breathing rate, and level of consciousness. If their pulse is weak or they are showing signs of deterioration, seek immediate medical assistance.",
    "Keep the Person Warm: Ensure the person is kept warm by covering them with blankets or clothing to prevent further heat loss and aid in maintaining body temperature.",
    "Maintain an Open Airway: Ensure the person's airway is clear and open. If necessary, position their head and neck to maintain proper alignment.",
    "Seek Medical Assistance: If the low pulse rate persists, is accompanied by severe symptoms (e.g., fainting, confusion, shortness of breath), or if the person is unresponsive, call for emergency medical assistance immediately.",
  ];

  List<String> concerningO2 = [
    "Encourage the person to take slow, deep breaths.",
    "If the person has a known respiratory condition or is experiencing severe symptoms, seek medical assistance.",
  ];

  List<String> lowO2 = [
    "Ensure the person is in a position that aids breathing, such as sitting upright.",
    "If available, provide supplemental oxygen if trained to do so.",
    "If the person is experiencing severe respiratory distress, is unresponsive, or has stopped breathing, call for emergency medical assistance immediately and initiate CPR if trained to do so.",
  ];

  List<String> advices = [];

  @override
  void initState() {
    super.initState();
    double.parse(data.blood_pressure_systolic) < 90 &&
            double.parse(data.blood_pressure_diastolic) < 60
        ? advices.addAll(lowPressure)
        : double.parse(data.blood_pressure_systolic) < 120 ||
                double.parse(data.blood_pressure_diastolic) < 80
            ? null
            : double.parse(data.blood_pressure_systolic) < 130 &&
                    double.parse(data.blood_pressure_diastolic) < 80
                ? advices.addAll(elevatedPressure)
                : double.parse(data.blood_pressure_systolic) < 140 ||
                        double.parse(data.blood_pressure_diastolic) < 90
                    ? advices.addAll(stage1Hypertension)
                    : advices.addAll(stage2Hypertension);
    double.parse(data.body_temperature) < 35.9
        ? advices.addAll(lowTemp)
        : double.parse(data.body_temperature) < 37.2
            ? null
            : double.parse(data.body_temperature) < 38.7
                ? advices.addAll(fever)
                : advices.addAll(fever);

    double.parse(data.pulse_rate) < 80 &&
                (DateTime.parse(gotpatient.dob).difference(DateTime.now()).inDays / 365)
                        .floor() <
                    1 ||
            double.parse(data.pulse_rate) < 70 &&
                (DateTime.parse(gotpatient.dob).difference(DateTime.now()).inDays / 365)
                        .floor() <
                    18 ||
            double.parse(data.pulse_rate) < 60 &&
                (DateTime.parse(gotpatient.dob).difference(DateTime.now()).inDays / 365)
                        .floor() >=
                    18
        ? advices.addAll(lowPulseRate)
        : double.parse(data.pulse_rate) > 160 &&
                    (DateTime.parse(gotpatient.dob).difference(DateTime.now()).inDays / 365)
                            .floor() <
                        1 ||
                double.parse(data.pulse_rate) > 100 &&
                    (DateTime.parse(gotpatient.dob).difference(DateTime.now()).inDays /
                                365)
                            .floor() >
                        1
            ? advices.addAll(highPulseRate)
            : null;
    double.parse(data.oxygen_saturation) < 91
        ? advices.addAll(lowO2)
        : double.parse(data.oxygen_saturation) < 96
            ? advices.addAll(concerningO2)
            : null;
    if (advices.isEmpty) {
      advices.add("Everything seems Normal, Continue staying Healthy");
    }
  }

  int currentIndex = 0;

  void goToPreviousWord() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
      }
    });
  }

  void goToNextWord() {
    setState(() {
      if (currentIndex < advices.length - 1) {
        currentIndex++;
      }
    });
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
                  Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      margin: const EdgeInsets.fromLTRB(20, 20, 20, 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: const Color.fromRGBO(255, 255, 255, 0.2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildInfoTile(
                                "Advice " + (currentIndex + 1).toString(),
                                advices[currentIndex],
                              ),
                            ],
                          ),
                        ],
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(10, 40, 10, 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: (currentIndex == 0)
                                ? Colors.grey
                                : Colors.white,
                            width: 4.0,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: IconButton(
                            iconSize: 40,
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: (currentIndex == 0)
                                  ? Colors.grey
                                  : Colors.white,
                              size: 30,
                            ),
                            onPressed: goToPreviousWord,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 60,
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(10, 40, 10, 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: (currentIndex == (advices.length - 1))
                                ? Colors.grey
                                : Colors.white,
                            width: 4.0,
                          ),
                        ),
                        child: IconButton(
                          iconSize: 40,
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: (currentIndex == (advices.length - 1))
                                ? Colors.grey
                                : Colors.white,
                            size: 30,
                          ),
                          onPressed: goToNextWord,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildInfoTile(String title, String description) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * 0.055,
            ),
            softWrap: true,
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * 0.047,
            ),
            overflow: TextOverflow.visible,
            softWrap: true,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
