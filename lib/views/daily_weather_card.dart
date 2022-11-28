import 'package:flutter/material.dart';

class DailyWeather extends StatelessWidget {
  final String abbr;
  final int temp;
  final int epochdate;

  const DailyWeather(
      {Key? key,
      required this.abbr,
      required this.temp,
      required this.epochdate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> weekdays = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar'
    ];

    String weekday = weekdays[
        DateTime.fromMillisecondsSinceEpoch(epochdate * 1000).weekday - 1];
    print(weekday);
    return Card(
      elevation: 2,
      color: Colors.transparent,
      child: Container(
        height: 120,
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text(abbr), Text('$temp ° C'), Text(weekday)],
        ),
      ),
    );
  }
}
