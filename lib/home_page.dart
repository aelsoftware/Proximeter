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

  bool started = false;

  double calculatedArea = 0.00;

  addLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {});
    points.add(LatLng(position.latitude, position.longitude));
  }

  @override
  void initState() {
    points.clear();
    super.initState();
  }

  @override
  checkGps() async {
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
        addLocation();
        setState(() {});
      }
    } else {
      print("GPS Service is not enabled, turn on GPS location");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Calculate Area Covered"),
      ),
      floatingActionButton: FloatingActionButton(
        isExtended: true,
        child: Container(
          width: 200,
          child: Row(
            children: [
              Text("Get Area"),
              Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
        onPressed: () {
          if (points.length > 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AreaPage(
                  area: calculatedArea,
                ),
              ),
            );
          } else {
            AlertDialog(
              icon: Icon(Icons.error_outline),
              title: Text("Please add atleast 4 points to continue"),
            );
          }
        },
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Selected Points",
              style: TextStyle(fontSize: 18),
            ),
            if (points.isNotEmpty)
              for (int x = 0; x < points.length; x++) ...[
                Row(
                  children: [
                    Text(points[x].latitude.toString()),
                    const Text(" , "),
                    Text(points[x].longitude.toString()),
                  ],
                ),
              ],
            SizedBox(
              height: 25,
            ),
            ElevatedButton(
              onPressed: () {
                checkGps();
                setState(() {});
              },
              child: Text("Mark point ${points.length + 1}"),
            ),
          ],
        ),
      ),
    );
  }
}
