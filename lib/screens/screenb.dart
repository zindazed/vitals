import 'package:flutter/material.dart';
import 'package:vital_monitor/logic/models/mysql.dart';

class ScreenB extends StatelessWidget {
  final MyData data;
  ScreenB({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen B'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text(data.device_id),
          onPressed: () {
            // Navigate back to ScreenA
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
