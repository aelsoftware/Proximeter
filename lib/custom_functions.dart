import 'package:flutter/material.dart';
import 'package:maps_toolkit/maps_toolkit.dart';

calculateArea(List<LatLng> points) {
  final areaInSquareMeters = SphericalUtil.computeArea(points);
  return areaInSquareMeters;
}
