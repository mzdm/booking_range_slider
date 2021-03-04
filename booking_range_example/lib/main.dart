import 'package:flutter/material.dart';
import 'package:booking_range_slider/booking_range_slider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String start = '';
  String end = '';
  bool isAvailable = false;

  void _do(BookingValues bookingValues) {
    setState(() {
      start = _addLeadingZeroIfNeeded(bookingValues.start);
      end = _addLeadingZeroIfNeeded(bookingValues.end);
      isAvailable = bookingValues.isAvailable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 300,
            child: BookingRangeSlider(
              onChanged: (value) {
                _do(value);
              },
              displayHandles: true,
              labelFrequency: TimeOfDay(hour: 1, minute: 0),
              initialTime: TimeOfDay(hour: 0, minute: 0),
              endingTime: TimeOfDay(hour: 6, minute: 0),
              division: TimeOfDay(hour: 0, minute: 10),
              values: <BookingValues>[
                BookingValues(
                  TimeOfDay(hour: 1, minute: 0),
                  TimeOfDay(hour: 2, minute: 0),
                ),
                BookingValues(
                  TimeOfDay(hour: 3, minute: 0),
                  TimeOfDay(hour: 3, minute: 30),
                ),
                BookingValues(
                  TimeOfDay(hour: 4, minute: 0),
                  TimeOfDay(hour: 5, minute: 0),
                  isAvailable: true,
                ),
                BookingValues(
                  TimeOfDay(hour: 5, minute: 30),
                  TimeOfDay(hour: 6, minute: 0),
                ),
              ],
            ),
          ),
          SizedBox(height: 50),
          Text(
            'Start: $start  ----  End: $end\n',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Available: ',
              ),
              Text(
                isAvailable.toString().toUpperCase(),
                style: TextStyle(
                  color: isAvailable ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _addLeadingZeroIfNeeded(TimeOfDay timeOfDay) {
  final hour = timeOfDay.hour;
  final min = timeOfDay.minute;

  var str = '';
  if (hour < 10) {
    str += '0$hour:';
  } else {
    str += '$hour:';
  }

  if (min < 10) {
    str += '0$min';
  } else {
    str += '$min';
  }
  return str;
}
