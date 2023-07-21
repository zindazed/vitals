import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vital_monitor/logic/models/mysql.dart';
import 'package:vital_monitor/main.dart';
import 'package:vital_monitor/screens/advice.dart';
import 'screenb.dart';
import 'package:vital_monitor/logic/models/userModel.dart';
import 'package:vital_monitor/logic/models/userProvider.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'global.dart';

// import 'package:mysql1/mysql1.dart';

// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChartData {
  final int x;
  final int y;

  ChartData(this.x, this.y);
}

class PatientDetails extends StatefulWidget {
  final MyData data;
  final User user;
  final MyPatients patient;
  const PatientDetails({
    Key? key,
    required this.data,
    required this.user,
    required this.patient,
  }) : super(key: key);

  @override
  _PatientDetailsState createState() =>
      _PatientDetailsState(data, user, patient);
}

class _PatientDetailsState extends State<PatientDetails> {
  List<MyData> dataList = [];
  List<MyData> dataList2 = [];
  MyData data;
  User gotuser;
  MyPatients gotpatient;
  String period = "seconds";
  String tperiod = "lateMorning";
  _PatientDetailsState(this.data, this.gotuser, this.gotpatient);
  Timer? timer;

  String vital_sign = 'Systolic Blood Pressure';
  final List<String> items = [
    'Systolic Blood Pressure',
    'Diastolic Blood Pressure',
    'Temperature',
    'Pulse Rate',
    'Oxygen Saturation',
  ];
  int currentIndex = 0;

  List<ChartData> cdata = [];
  List<ChartData> cdata2 = [];

  List<charts.Series<ChartData, int>> getChartDataSeries() {
    return [
      charts.Series(
        id: 'chartData',
        data: cdata,
        domainFn: (ChartData chartData, _) => chartData.x,
        measureFn: (ChartData chartData, _) => chartData.y,
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      ),
    ];
  }

  List<charts.Series<ChartData, int>> getChartDataSeries2() {
    return [
      charts.Series(
        id: 'chartData',
        data: cdata2,
        domainFn: (ChartData chartData, _) => chartData.x,
        measureFn: (ChartData chartData, _) => chartData.y,
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      ),
    ];
  }

  // Function to sort data into different lists based on created time periods
  Map<String, List<MyData>> sortDataByTimePeriod(List<MyData> dataList) {
    Map<String, List<MyData>> sortedData = {
      'Early Morning': [],
      'Late Morning': [],
      'Afternoon': [],
      'Evening': [],
      'Early Night': [],
      'Late Night': [],
    };

    dataList.forEach((data) {
      TimeOfDay timeOfDay =
          TimeOfDay.fromDateTime(DateTime.parse(data.created_date));
      if (timeOfDay.hour >= 5 && timeOfDay.hour < 9) {
        sortedData['Early Morning']!.add(data);
      } else if (timeOfDay.hour >= 9 && timeOfDay.hour < 12) {
        sortedData['Late Morning']!.add(data);
      } else if (timeOfDay.hour >= 12 && timeOfDay.hour < 15) {
        sortedData['Afternoon']!.add(data);
      } else if (timeOfDay.hour >= 15 && timeOfDay.hour < 19) {
        sortedData['Evening']!.add(data);
      } else if (timeOfDay.hour >= 19 || timeOfDay.hour < 0) {
        sortedData['Early Night']!.add(data);
      } else {
        sortedData['Late Night']!.add(data);
      }
    });

    return sortedData;
  }

  @override
  void initState() {
    super.initState(); // Call the fetchData method to retrieve the data
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() async {
    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) async {
      fetchData2();
      if (mounted)
        setState(() {
          cdata.clear();
          for (MyData vitals in dataList) {
            if (period == "seconds") {
              cdata.add(ChartData(
                  DateTime.parse(vitals.created_date)
                      .difference(DateTime.parse(
                          dataList[dataList.length - 1].created_date))
                      .inSeconds,
                  double.parse(vitals.getVital(vital_sign)).round()));
            } else if (period == "minutes") {
              cdata.add(ChartData(
                  DateTime.parse(vitals.created_date)
                      .difference(DateTime.parse(
                          dataList[dataList.length - 1].created_date))
                      .inMinutes,
                  double.parse(vitals.getVital(vital_sign)).round()));
            } else if (period == "hours") {
              cdata.add(ChartData(
                  DateTime.parse(vitals.created_date)
                      .difference(DateTime.parse(
                          dataList[dataList.length - 1].created_date))
                      .inHours,
                  double.parse(vitals.getVital(vital_sign)).round()));
            } else if (period == "days") {
              cdata.add(ChartData(
                  DateTime.parse(vitals.created_date)
                      .difference(DateTime.parse(
                          dataList[dataList.length - 1].created_date))
                      .inDays,
                  double.parse(vitals.getVital(vital_sign)).round()));
            }
          }
        });
    });
  }

  Future<List<MyData>> fetchData() async {
    final url = '$host/graphapi.php';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'interval': period,
        'device_id': data.device_id,
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return List<MyData>.from(jsonData.map((data) => MyData.fromJson(data)));
    } else {
      throw Exception('Failed to retrieve data');
    }
  }

  Future<List<MyData>> fetchData3() async {
    final response = await http.get(Uri.parse('$host/graphapi2.php'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return List<MyData>.from(jsonData.map((data) => MyData.fromJson(data)));
    } else {
      throw Exception('Failed to retrieve data');
    }
  }

  Future<void> fetchData2() async {
    try {
      List<MyData> fetchedData =
          await fetchData(); // Call the fetchData method that retrieves data
      List<MyData> fetchedData2 = await fetchData3();
      if (mounted) {
        setState(() {
          dataList = fetchedData;
          dataList2 = fetchedData2;
          data = dataList[0];
        });
      }
    } catch (e) {
      // Handle error cases
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (dataList.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    Map<String, List<MyData>> sortedData = sortDataByTimePeriod(dataList2);

    //separate lists for each time period
    List<MyData> earlyMorningData = sortedData['Early Morning']!;
    List<MyData> lateMorningData = sortedData['Late Morning']!;
    List<MyData> afternoonData = sortedData['Afternoon']!;
    List<MyData> eveningData = sortedData['Evening']!;
    List<MyData> earlyNightData = sortedData['Early Night']!;
    List<MyData> lateNightData = sortedData['Late Night']!;

    cdata2.clear();

    if (tperiod == "earlyMorning") {
      for (MyData vitals in earlyMorningData) {
        cdata2.add(ChartData(
            DateTime.parse(vitals.created_date)
                .difference(DateTime.parse(
                    earlyMorningData[earlyMorningData.length - 1].created_date))
                .inSeconds,
            double.parse(vitals.getVital(vital_sign)).round()));
      }
    } else if (tperiod == "lateMorning") {
      for (MyData vitals in lateMorningData) {
        cdata2.add(ChartData(
            DateTime.parse(vitals.created_date)
                .difference(DateTime.parse(
                    lateMorningData[lateMorningData.length - 1].created_date))
                .inSeconds,
            double.parse(vitals.getVital(vital_sign)).round()));
      }
    } else if (tperiod == "afternoon") {
      for (MyData vitals in afternoonData) {
        cdata2.add(ChartData(
            DateTime.parse(vitals.created_date)
                .difference(DateTime.parse(
                    afternoonData[afternoonData.length - 1].created_date))
                .inSeconds,
            double.parse(vitals.getVital(vital_sign)).round()));
      }
    } else if (tperiod == "evening") {
      for (MyData vitals in eveningData) {
        cdata2.add(ChartData(
            DateTime.parse(vitals.created_date)
                .difference(DateTime.parse(
                    eveningData[eveningData.length - 1].created_date))
                .inSeconds,
            double.parse(vitals.getVital(vital_sign)).round()));
      }
    } else if (tperiod == "earlyNight") {
      for (MyData vitals in earlyNightData) {
        cdata2.add(ChartData(
            DateTime.parse(vitals.created_date)
                .difference(DateTime.parse(
                    earlyNightData[earlyNightData.length - 1].created_date))
                .inSeconds,
            double.parse(vitals.getVital(vital_sign)).round()));
      }
    } else if (tperiod == "lateNight") {
      for (MyData vitals in lateNightData) {
        cdata2.add(ChartData(
            DateTime.parse(vitals.created_date)
                .difference(DateTime.parse(
                    lateNightData[lateNightData.length - 1].created_date))
                .inSeconds,
            double.parse(vitals.getVital(vital_sign)).round()));
      }
    }

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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        color: Colors.white,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      Text(gotuser.username!,
                          style: TextStyle(fontSize: 20, color: Colors.white)),
                      InformationIconPopup(),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: MediaQuery.of(context).size.height * 0.15,
                            margin: const EdgeInsets.fromLTRB(10, 5, 2, 0),
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(0),
                              ),
                              color: const Color.fromRGBO(255, 255, 255, 0.2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Blood Pressure',
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.047,
                                        color: Colors.white)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                            dataList.first
                                                    .blood_pressure_systolic +
                                                "/" +
                                                dataList.first
                                                    .blood_pressure_diastolic,
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.08,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text('mmHg',
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.042,
                                              color: Colors.white,
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                    double.parse(dataList.first.blood_pressure_systolic) < 90 &&
                                            double.parse(dataList.first.blood_pressure_diastolic) <
                                                60
                                        ? "Low"
                                        : double.parse(dataList.first.blood_pressure_systolic) < 120 ||
                                                double.parse(dataList.first.blood_pressure_diastolic) <
                                                    80
                                            ? "Normal"
                                            : double.parse(dataList.first.blood_pressure_systolic) < 130 &&
                                                    double.parse(dataList.first.blood_pressure_diastolic) <
                                                        80
                                                ? "Elevated"
                                                : double.parse(dataList.first.blood_pressure_systolic) < 140 ||
                                                        double.parse(dataList.first.blood_pressure_diastolic) <
                                                            90
                                                    ? "Stage 1 Hypertension"
                                                    : 'Stage 2 Hypertension',
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.047,
                                        color: double.parse(dataList.first.blood_pressure_systolic) < 90 &&
                                                double.parse(dataList.first.blood_pressure_diastolic) <
                                                    60
                                            ? Colors.blue
                                            : double.parse(dataList.first.blood_pressure_systolic) < 120 ||
                                                    double.parse(dataList.first.blood_pressure_diastolic) <
                                                        80
                                                ? Colors.green
                                                : double.parse(dataList.first.blood_pressure_systolic) <
                                                            130 &&
                                                        double.parse(dataList.first.blood_pressure_diastolic) < 80
                                                    ? Colors.yellow
                                                    : double.parse(dataList.first.blood_pressure_systolic) < 140 || double.parse(dataList.first.blood_pressure_diastolic) < 90
                                                        ? Colors.orange
                                                        : Colors.red,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: MediaQuery.of(context).size.height * 0.15,
                            margin: const EdgeInsets.fromLTRB(2, 5, 10, 0),
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(20),
                              ),
                              color: const Color.fromRGBO(255, 255, 255, 0.2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Temperature',
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.047,
                                        color: Colors.white)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Text(dataList.first.body_temperature,
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.08,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text('°C',
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.042,
                                              color: Colors.white,
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                    double.parse(dataList.first.body_temperature) <
                                            35.9
                                        ? 'Low'
                                        : double.parse(dataList.first.body_temperature) <
                                                37.2
                                            ? "Normal"
                                            : double.parse(dataList.first
                                                        .body_temperature) <
                                                    38.7
                                                ? "Moderate Fever"
                                                : "High Fever",
                                    style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width *
                                            0.047,
                                        color: double.parse(dataList
                                                    .first.body_temperature) <
                                                35.9
                                            ? Colors.blue
                                            : double.parse(dataList.first
                                                        .body_temperature) <
                                                    37.2
                                                ? Colors.green
                                                : double.parse(dataList.first
                                                            .body_temperature) <
                                                        38.7
                                                    ? Colors.orange
                                                    : Colors.red,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.45,
                            height: MediaQuery.of(context).size.height * 0.15,
                            margin: const EdgeInsets.fromLTRB(2, 5, 2, 0),
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(0),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                              color: const Color.fromRGBO(255, 255, 255, 0.2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Pulse Rate',
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.047,
                                        color: Colors.white)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Text(dataList.first.pulse_rate,
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.08,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text('bpm',
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.042,
                                              color: Colors.white,
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                    double.parse(dataList.first.pulse_rate) < 80 &&
                                                (DateTime.parse(gotpatient.dob).difference(DateTime.now()).inDays / 365).floor() <
                                                    1 ||
                                            double.parse(dataList.first.pulse_rate) < 70 &&
                                                (DateTime.parse(gotpatient.dob).difference(DateTime.now()).inDays / 365).floor() <
                                                    18 ||
                                            double.parse(dataList.first.pulse_rate) < 60 &&
                                                (DateTime.parse(gotpatient.dob).difference(DateTime.now()).inDays / 365)
                                                        .floor() >=
                                                    18
                                        ? "Low"
                                        : double.parse(dataList.first.pulse_rate) > 160 && (DateTime.parse(gotpatient.dob).difference(DateTime.now()).inDays / 365).floor() < 1 ||
                                                double.parse(dataList.first.pulse_rate) > 100 &&
                                                    (DateTime.parse(gotpatient.dob).difference(DateTime.now()).inDays / 365).floor() >
                                                        1
                                            ? "High"
                                            : "Normal",
                                    style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width *
                                            0.047,
                                        color: double.parse(dataList.first.pulse_rate) < 80 && (DateTime.parse(gotpatient.dob).difference(DateTime.now()).inDays / 365).floor() < 1 ||
                                                double.parse(dataList.first.pulse_rate) < 70 &&
                                                    (DateTime.parse(gotpatient.dob).difference(DateTime.now()).inDays / 365).floor() < 18 ||
                                                double.parse(dataList.first.pulse_rate) < 60 && (DateTime.parse(gotpatient.dob).difference(DateTime.now()).inDays / 365).floor() >= 18
                                            ? Colors.blue
                                            : double.parse(dataList.first.pulse_rate) > 160 && (DateTime.parse(gotpatient.dob).difference(DateTime.now()).inDays / 365).floor() < 1 || double.parse(dataList.first.pulse_rate) > 100 && (DateTime.parse(gotpatient.dob).difference(DateTime.now()).inDays / 365).floor() > 1
                                                ? Colors.red
                                                : Colors.green,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.45,
                            height: MediaQuery.of(context).size.height * 0.15,
                            margin: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                              color: const Color.fromRGBO(255, 255, 255, 0.2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('O2 Saturation',
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.047,
                                        color: Colors.white)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Text(dataList.first.oxygen_saturation,
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.08,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text('%',
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.042,
                                              color: Colors.white,
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                    double.parse(dataList
                                                .first.oxygen_saturation) <
                                            91
                                        ? "Low"
                                        : double.parse(dataList
                                                    .first.oxygen_saturation) <
                                                96
                                            ? "Concerning"
                                            : "Normal",
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.047,
                                        color: double.parse(dataList
                                                    .first.oxygen_saturation) <
                                                91
                                            ? Colors.red
                                            : double.parse(dataList.first
                                                        .oxygen_saturation) <
                                                    96
                                                ? Colors.yellow
                                                : Colors.green,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 30, 10, 0),
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    color: Colors.white,
                    child: Center(
                        child: Text(
                      "Analytics per unit Time",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    )),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Center(
                          child: SizedBox(
                            height: 50,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      currentIndex = index;
                                      vital_sign = items[index];
                                    });
                                  },
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: index == currentIndex
                                          ? Color.fromRGBO(0, 33, 71, 1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        color: index == currentIndex
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert),
                            onSelected: (value) {
                              setState(() {
                                period = value;
                                cdata.clear();
                                for (MyData vitals in dataList) {
                                  if (period == "seconds") {
                                    cdata.add(ChartData(
                                        DateTime.parse(vitals.created_date)
                                            .difference(DateTime.parse(
                                                dataList[dataList.length - 1]
                                                    .created_date))
                                            .inSeconds,
                                        double.parse(
                                                vitals.getVital(vital_sign))
                                            .round()));
                                  } else if (period == "minutes") {
                                    cdata.add(ChartData(
                                        DateTime.parse(vitals.created_date)
                                            .difference(DateTime.parse(
                                                dataList[dataList.length - 1]
                                                    .created_date))
                                            .inMinutes,
                                        double.parse(
                                                vitals.getVital(vital_sign))
                                            .round()));
                                  } else if (period == "hours") {
                                    cdata.add(ChartData(
                                        DateTime.parse(vitals.created_date)
                                            .difference(DateTime.parse(
                                                dataList[dataList.length - 1]
                                                    .created_date))
                                            .inHours,
                                        double.parse(
                                                vitals.getVital(vital_sign))
                                            .round()));
                                  } else if (period == "days") {
                                    cdata.add(ChartData(
                                        DateTime.parse(vitals.created_date)
                                            .difference(DateTime.parse(
                                                dataList[dataList.length - 1]
                                                    .created_date))
                                            .inDays,
                                        double.parse(
                                                vitals.getVital(vital_sign))
                                            .round()));
                                  }
                                }
                              });
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'seconds',
                                child: Text('Per second'),
                              ),
                              PopupMenuItem<String>(
                                value: 'minutes',
                                child: Text('Per minute'),
                              ),
                              PopupMenuItem<String>(
                                value: 'hours',
                                child: Text('Per hour'),
                              ),
                              PopupMenuItem<String>(
                                value: 'days',
                                child: Text('Per day'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height: 400,
                            child: charts.LineChart(
                              getChartDataSeries(),
                              animate: true,
                              domainAxis: charts.NumericAxisSpec(
                                tickProviderSpec:
                                    charts.BasicNumericTickProviderSpec(
                                  desiredTickCount: 5,
                                ),
                                renderSpec: charts.GridlineRendererSpec(
                                  labelStyle: charts.TextStyleSpec(
                                    color: charts.MaterialPalette.black,
                                    fontSize: 12,
                                  ),
                                  lineStyle: charts.LineStyleSpec(
                                    color: charts.MaterialPalette.black,
                                  ),
                                  axisLineStyle: charts.LineStyleSpec(
                                    color: charts.MaterialPalette.black,
                                  ),
                                ),
                                // Custom tick formatter to divide the displayed values by 60,000
                                tickFormatterSpec:
                                    charts.BasicNumericTickFormatterSpec(
                                  (num? value) => (value! < 60)
                                      ? (value.round().toString() + " seconds")
                                      : (value < 3600)
                                          ? (value / 60).round().toString() +
                                              " minutes"
                                          : (value < 86400)
                                              ? (value / 3600)
                                                      .round()
                                                      .toString() +
                                                  " hours"
                                              : (value / (3600 * 24))
                                                      .round()
                                                      .toString() +
                                                  " days", // Divide by 60,000 and display with 1 decimal place
                                ),
                              ),
                              primaryMeasureAxis: charts.NumericAxisSpec(
                                tickProviderSpec:
                                    charts.BasicNumericTickProviderSpec(
                                  desiredTickCount: 5,
                                ),
                                renderSpec: charts.GridlineRendererSpec(
                                  labelStyle: charts.TextStyleSpec(
                                    color: charts.MaterialPalette.black,
                                    fontSize: 12,
                                  ),
                                  lineStyle: charts.LineStyleSpec(
                                    color: charts.MaterialPalette.black,
                                  ),
                                  axisLineStyle: charts.LineStyleSpec(
                                    color: charts.MaterialPalette.black,
                                  ),
                                ),
                              ),
                            )),
                        Center(
                          child: Text(
                            "Time",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 30, 10, 0),
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    color: Colors.white,
                    child: Center(
                        child: Text(
                      "Analytics Per Time Period",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    )),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Center(
                          child: SizedBox(
                            height: 50,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      currentIndex = index;
                                      vital_sign = items[index];

                                      cdata2.clear();

                                      if (tperiod == "earlyMorning") {
                                        for (MyData vitals
                                            in earlyMorningData) {
                                          cdata2.add(ChartData(
                                              DateTime.parse(
                                                      vitals.created_date)
                                                  .difference(DateTime.parse(
                                                      earlyMorningData[
                                                              earlyMorningData
                                                                      .length -
                                                                  1]
                                                          .created_date))
                                                  .inSeconds,
                                              double.parse(vitals
                                                      .getVital(vital_sign))
                                                  .round()));
                                        }
                                      } else if (tperiod == "lateMorning") {
                                        for (MyData vitals in lateMorningData) {
                                          cdata2.add(ChartData(
                                              DateTime.parse(
                                                      vitals.created_date)
                                                  .difference(DateTime.parse(
                                                      lateMorningData[
                                                              lateMorningData
                                                                      .length -
                                                                  1]
                                                          .created_date))
                                                  .inSeconds,
                                              double.parse(vitals
                                                      .getVital(vital_sign))
                                                  .round()));
                                        }
                                      } else if (tperiod == "afternoon") {
                                        for (MyData vitals in afternoonData) {
                                          cdata2.add(ChartData(
                                              DateTime.parse(
                                                      vitals.created_date)
                                                  .difference(DateTime.parse(
                                                      afternoonData[
                                                              afternoonData
                                                                      .length -
                                                                  1]
                                                          .created_date))
                                                  .inSeconds,
                                              double.parse(vitals
                                                      .getVital(vital_sign))
                                                  .round()));
                                        }
                                      } else if (tperiod == "evening") {
                                        for (MyData vitals in eveningData) {
                                          cdata2.add(ChartData(
                                              DateTime.parse(
                                                      vitals.created_date)
                                                  .difference(DateTime.parse(
                                                      eveningData[eveningData
                                                                  .length -
                                                              1]
                                                          .created_date))
                                                  .inSeconds,
                                              double.parse(vitals
                                                      .getVital(vital_sign))
                                                  .round()));
                                        }
                                      } else if (tperiod == "earlyNight") {
                                        for (MyData vitals in earlyNightData) {
                                          cdata2.add(ChartData(
                                              DateTime.parse(
                                                      vitals.created_date)
                                                  .difference(DateTime.parse(
                                                      earlyNightData[
                                                              earlyNightData
                                                                      .length -
                                                                  1]
                                                          .created_date))
                                                  .inSeconds,
                                              double.parse(vitals
                                                      .getVital(vital_sign))
                                                  .round()));
                                        }
                                      } else if (tperiod == "lateNight") {
                                        for (MyData vitals in lateNightData) {
                                          cdata2.add(ChartData(
                                              DateTime.parse(
                                                      vitals.created_date)
                                                  .difference(DateTime.parse(
                                                      lateNightData[
                                                              lateNightData
                                                                      .length -
                                                                  1]
                                                          .created_date))
                                                  .inSeconds,
                                              double.parse(vitals
                                                      .getVital(vital_sign))
                                                  .round()));
                                        }
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: index == currentIndex
                                          ? Color.fromRGBO(0, 33, 71, 1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        color: index == currentIndex
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert),
                            onSelected: (value) {
                              setState(() {
                                tperiod = value;
                                cdata2.clear();

                                if (tperiod == "earlyMorning") {
                                  for (MyData vitals in earlyMorningData) {
                                    cdata2.add(ChartData(
                                        DateTime.parse(vitals.created_date)
                                            .difference(DateTime.parse(
                                                earlyMorningData[
                                                        earlyMorningData
                                                                .length -
                                                            1]
                                                    .created_date))
                                            .inSeconds,
                                        double.parse(
                                                vitals.getVital(vital_sign))
                                            .round()));
                                  }
                                } else if (tperiod == "lateMorning") {
                                  for (MyData vitals in lateMorningData) {
                                    cdata2.add(ChartData(
                                        DateTime.parse(vitals.created_date)
                                            .difference(DateTime.parse(
                                                lateMorningData[
                                                        lateMorningData.length -
                                                            1]
                                                    .created_date))
                                            .inSeconds,
                                        double.parse(
                                                vitals.getVital(vital_sign))
                                            .round()));
                                  }
                                } else if (tperiod == "afternoon") {
                                  for (MyData vitals in afternoonData) {
                                    cdata2.add(ChartData(
                                        DateTime.parse(vitals.created_date)
                                            .difference(DateTime.parse(
                                                afternoonData[
                                                        afternoonData.length -
                                                            1]
                                                    .created_date))
                                            .inSeconds,
                                        double.parse(
                                                vitals.getVital(vital_sign))
                                            .round()));
                                  }
                                } else if (tperiod == "evening") {
                                  for (MyData vitals in eveningData) {
                                    cdata2.add(ChartData(
                                        DateTime.parse(vitals.created_date)
                                            .difference(DateTime.parse(
                                                eveningData[
                                                        eveningData.length - 1]
                                                    .created_date))
                                            .inSeconds,
                                        double.parse(
                                                vitals.getVital(vital_sign))
                                            .round()));
                                  }
                                } else if (tperiod == "earlyNight") {
                                  for (MyData vitals in earlyNightData) {
                                    cdata2.add(ChartData(
                                        DateTime.parse(vitals.created_date)
                                            .difference(DateTime.parse(
                                                earlyNightData[
                                                        earlyNightData.length -
                                                            1]
                                                    .created_date))
                                            .inSeconds,
                                        double.parse(
                                                vitals.getVital(vital_sign))
                                            .round()));
                                  }
                                } else if (tperiod == "lateNight") {
                                  for (MyData vitals in lateNightData) {
                                    cdata2.add(ChartData(
                                        DateTime.parse(vitals.created_date)
                                            .difference(DateTime.parse(
                                                lateNightData[
                                                        lateNightData.length -
                                                            1]
                                                    .created_date))
                                            .inSeconds,
                                        double.parse(
                                                vitals.getVital(vital_sign))
                                            .round()));
                                  }
                                }
                              });
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'earlyMorning',
                                child: Text('Early Morning 5:00 - 9:00'),
                              ),
                              PopupMenuItem<String>(
                                value: 'lateMorning',
                                child: Text('Late Morning 9:00 - 12:00'),
                              ),
                              PopupMenuItem<String>(
                                value: 'afternoon',
                                child: Text('Afternoon 12:00 - 15:00'),
                              ),
                              PopupMenuItem<String>(
                                value: 'evening',
                                child: Text('Evening 15:00 - 19:00'),
                              ),
                              PopupMenuItem<String>(
                                value: 'earlyNight',
                                child: Text('Early Night 19:00 - 00:00'),
                              ),
                              PopupMenuItem<String>(
                                value: 'lateNight',
                                child: Text('Late Night 00:00 - 5:00'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 400,
                          child: charts.LineChart(
                            getChartDataSeries2(),
                            animate: true,
                            domainAxis: charts.NumericAxisSpec(
                              tickProviderSpec:
                                  charts.BasicNumericTickProviderSpec(
                                      desiredTickCount: 5),
                              renderSpec: charts.GridlineRendererSpec(
                                labelStyle: charts.TextStyleSpec(
                                  color: charts.MaterialPalette.black,
                                  fontSize: 12,
                                ),
                                lineStyle: charts.LineStyleSpec(
                                  color: charts.MaterialPalette.black,
                                ),
                                axisLineStyle: charts.LineStyleSpec(
                                  color: charts.MaterialPalette.black,
                                ),
                              ),
                            ),
                            primaryMeasureAxis: charts.NumericAxisSpec(
                              tickProviderSpec:
                                  charts.BasicNumericTickProviderSpec(
                                      desiredTickCount: 5),
                              renderSpec: charts.GridlineRendererSpec(
                                labelStyle: charts.TextStyleSpec(
                                  color: charts.MaterialPalette.black,
                                  fontSize: 12,
                                ),
                                lineStyle: charts.LineStyleSpec(
                                  color: charts.MaterialPalette.black,
                                ),
                                axisLineStyle: charts.LineStyleSpec(
                                  color: charts.MaterialPalette.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            period.toUpperCase(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(0, 33, 71,
                          1), // Set the button background color to green
                      side: BorderSide.none,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Advice(data: data, gotpatient: gotpatient)),
                      );
                    },
                    child: Container(
                        margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: const Color.fromRGBO(255, 255, 255, 0),
                          border: Border.all(width: 2.0, color: Colors.white),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Get Advice",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                )),
                          ],
                        )),
                  ),
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
