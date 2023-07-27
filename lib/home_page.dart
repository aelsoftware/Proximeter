import 'dart:async';
import 'package:flutter/material.dart';
import 'package:maps_toolkit/maps_toolkit.dart';

import 'package:geolocator/geolocator.dart';

import 'area_page.dart';
import 'custom_functions.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  late StreamSubscription<Position> positionStream;

  List<LatLng> points = [];

  String startPointText = "Mark Start Point";
  String endPointText = "Mark End Point";

  bool started = false;

  double calculatedArea = 0.00;

  @override
  checkGps() async {
    points.clear();
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          print("'Location permissions are permanently denied");
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }

      if (haspermission) {
        setState(() {});

        getLocation();
      }
    } else {
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {});
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {});
    Timer.periodic(Duration(seconds: 5), (timer) {
      points.add(LatLng(position.latitude, position.longitude));
      if (points.length > 3) {
        calculatedArea = calculateArea(points);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Calculate Area Covered"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                started = !started;
                setState(() {});
                checkGps();

                if (started == false && points.length > 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AreaPage(
                        area: calculatedArea,
                      ),
                    ),
                  );
                } else {
                  if (points.length < 3) {
                    const AlertDialog(
                      icon: Icon(Icons.error_outlined),
                      title: Text("Please move around, to add more points"),
                    );
                  }
                }
              },
              child: Text(started == true ? endPointText : startPointText),
            ),
          ],
        ),
      ),
    );
  }
}
