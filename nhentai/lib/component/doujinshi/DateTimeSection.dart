import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhentai/Constant.dart';

class DateTimeSection extends StatefulWidget {
  final int timeMillis;

  const DateTimeSection({Key? key, required this.timeMillis}) : super(key: key);

  @override
  _DateTimeSectionState createState() => _DateTimeSectionState();
}

class _DateTimeSectionState extends State<DateTimeSection> {
  @override
  Widget build(BuildContext context) {
    DateTime uploadedDate =
        DateTime.fromMillisecondsSinceEpoch(widget.timeMillis);
    return Text(
      'Uploaded at: ${DateFormat('hh:mm aaa - EEE, MMM d, yyyy').format(uploadedDate)}',
      style: TextStyle(
          fontFamily: Constant.NUNITO_REGULAR,
          fontSize: 16,
          color: Colors.white),
    );
  }
}
