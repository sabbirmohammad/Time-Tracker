import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flip_card/flip_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Wakelock.enable(); // Keep the screen on

    return MaterialApp(
      title: 'Digital Clock',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black, // Set the background color to black
        primarySwatch: Colors.blue,
      ),
      home: const DigitalClock(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DigitalClock extends StatefulWidget {
  const DigitalClock({super.key});

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  late String _timeString;

  late ValueNotifier<int> hourNotifier;
  late ValueNotifier<int> minuteNotifier;
  late ValueNotifier<int> secondNotifier;
  ValueNotifier<bool> is24HourClock = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _timeString = _formatDateTime(DateTime.now());

    final DateTime now = DateTime.now();
    int hour = now.hour;
    int minute = now.minute;
    int second = now.second;

    hourNotifier = ValueNotifier(hour);
    minuteNotifier = ValueNotifier(minute);
    secondNotifier = ValueNotifier(second);

    Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
  }

  @override
  void dispose() {
    hourNotifier.dispose();
    minuteNotifier.dispose();
    secondNotifier.dispose();
    is24HourClock.dispose();
    super.dispose();
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedDateTime;

      // Update the hour, minute, and second values using notifiers
      hourNotifier.value = now.hour;
      minuteNotifier.value = now.minute;
      secondNotifier.value = now.second;
    });
  }

  void _toggleClockMode() {
    // Toggle between 12-hour and 24-hour clock modes
    is24HourClock.value = !is24HourClock.value;
  }

  String _formatDateTime(DateTime dateTime) {
    int hour = is24HourClock.value ? dateTime.hour : dateTime.hour % 12;

    if (hour == 0) {
      hour = is24HourClock.value ? 0 : 12;
    }

    return "${hour.toString().padLeft(2, '0')}\n${dateTime.minute.toString().padLeft(2, '0')}\n${dateTime.second.toString().padLeft(2, '0')}";
  }

  Widget _buildFlipCard(ValueNotifier<int> notifier, String value) {
    return ValueListenableBuilder<int>(
      valueListenable: notifier,
      builder: (context, number, child) {
        return GestureDetector(
          onDoubleTap: () {
            _showSwitchClockFormatDialog();
          },
          child: FlipCard(
            direction: FlipDirection.VERTICAL,
            front: Container(
              alignment: Alignment.center,
              child: Text(
                value,
                style: GoogleFonts.rubik(
                  textStyle: const TextStyle(fontSize: 200, fontWeight: FontWeight.bold, color: Colors.white), // Set the font color to white
                ),
              ),
            ),
            back: Container(
              alignment: Alignment.center,
              child: Text(
                value,
                style: GoogleFonts.rubik(
                  textStyle: const TextStyle(fontSize: 200, fontWeight: FontWeight.bold, color: Colors.white), // Set the font color to white
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSwitchClockFormatDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Set the border radius
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Switch Format ?",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20), // Set the font color to white
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          is24HourClock.value = !is24HourClock.value;
                        });
                        Navigator.pop(context);
                      },
                      child: Text("Yes", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), // Set the font color to white
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("No", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), // Set the font color to white
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildFlipCard(hourNotifier, _timeString.split('\n')[0]), // Hour
            _buildFlipCard(minuteNotifier, _timeString.split('\n')[1]), // Minute
            _buildFlipCard(secondNotifier, _timeString.split('\n')[2]), // Second
          ],
        ),
      ),
    );
  }
}
