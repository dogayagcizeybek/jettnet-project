import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jettnet_project/main.dart';
import 'package:jettnet_project/services/auth.dart';
import 'package:jettnet_project/views/daily_weather_card.dart';

import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String sehir = 'Denizli';
  String? uid;
  var locationData;
  var Key;
  String apiKey = "y28amEFta50t9ca1fi2Fg39JGQfJ07hL";

  Position? position;

  Map<String, List> dataMap = {
    "temps": List.filled(5, 30),
    "abbrs": List.filled(5, "Gunesli"),
    "epochdates": List.filled(5, 0)
  };

  Future<void> getDevicePosition() async {
    position = await _determinePosition();
    print(position!.latitude);
  }

  Future<void> getLocationTemperature() async {
    var response = await http.get(Uri.parse(
        "http://dataservice.accuweather.com/forecasts/v1/daily/5day/$Key?apikey=$apiKey&language=tr"));
    var temperatureDataParsed = jsonDecode(response.body);

    setState(() {
      for (int i = 0; i < dataMap["temps"]!.length; i++) {
        dataMap["temps"]![i] = ((((temperatureDataParsed["DailyForecasts"][i]
                                ["Temperature"]["Minimum"]["Value"] +
                            temperatureDataParsed["DailyForecasts"][i]
                                ["Temperature"]["Maximum"]["Value"]) ~/
                        2) -
                    30) ~/
                1.80)
            .round();
        dataMap["abbrs"]![i] =
            temperatureDataParsed["DailyForecasts"][i]["Day"]["IconPhrase"];
        dataMap["epochdates"]![i] =
            temperatureDataParsed["DailyForecasts"][i]["EpochDate"];
        print(temperatureDataParsed["DailyForecasts"][i]["EpochDate"]);
      }
      box!.put(uid, dataMap);
    });
  }

  Future<void> getLocationData() async {
    locationData = await http.get(Uri.parse(
        "http://dataservice.accuweather.com/locations/v1/cities/search?apikey=$apiKey=$sehir"));
    var locationDataParsed = jsonDecode(locationData.body);
    Key = locationDataParsed['Key'];
  }

  Future<void> getLocationDataLatLong() async {
    locationData = await http.get(Uri.parse(
        "http://dataservice.accuweather.com/locations/v1/cities/geoposition/search?apikey=$apiKey&q=${position!.latitude}%2C${position!.longitude}"));
    // var locationDataParsed = jsonDecode((locationData.body));
    var locationDataParsed = jsonDecode(utf8.decode(locationData.bodyBytes));
    print(locationDataParsed.toString());
    Key = locationDataParsed['Key'];
    sehir = locationDataParsed["LocalizedName"];
    print(Key);
  }

  Future<void> getDataFromAPI() async {
    print("basiliyor");
    await getDevicePosition();
    print("basildi");
    await getLocationDataLatLong();
    getLocationTemperature();
  }

  void getDataFromAPIbyCity() async {
    await getLocationData();
    getLocationTemperature();
  }

  @override
  void initState() {
    Auth _auth = Auth();

    uid = _auth.getUserId();
    print(uid);
    if (box!.get(uid) != null) {
      print(box!.get(uid));
      dataMap = Map<String, List>.from(box!.get(uid));
    }
    getDataFromAPI();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                Provider.of<Auth>(context, listen: false).signOut();
                print('logout tıklandı');
              },
            )
          ],
        ),
        body: Container(
          child: dataMap["temps"]![0] == null
              ? Center(child: CircularProgressIndicator())
              : Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 60,
                          width: 60,
                          child: Text(dataMap["abbrs"]![0]),
                        ),
                        Text(
                          '${dataMap["temps"]![0]}° C',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 70,
                              shadows: <Shadow>[
                                Shadow(
                                    color: Colors.black38,
                                    blurRadius: 5,
                                    offset: Offset(-3, 3))
                              ]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '$sehir',
                              style: TextStyle(fontSize: 30, shadows: <Shadow>[
                                Shadow(
                                    color: Colors.black38,
                                    blurRadius: 5,
                                    offset: Offset(-3, 3))
                              ]),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 120,
                        ),
                        buildDailyWeatherCards(context)
                      ],
                    ),
                  )),
        ));
  }

  Container buildDailyWeatherCards(BuildContext context) {
    List<Widget> cards = List.filled(
        5,
        DailyWeather(
            abbr: dataMap["abbrs"]![0],
            temp: dataMap["temps"]![0],
            epochdate: dataMap["epochdates"]![0]));

    for (int i = 0; i < cards.length; i++) {
      cards[i] = DailyWeather(
          abbr: dataMap["abbrs"]![i],
          temp: dataMap["temps"]![i],
          epochdate: dataMap["epochdates"]![i]);
    }

    return Container(
      height: 120,
      width: MediaQuery.of(context).size.width * 0.9,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: cards,
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
