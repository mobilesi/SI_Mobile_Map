import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';

import 'marker_data.dart';

class SimpleMapController extends ChangeNotifier {

  List<MarkerData>? listMarker;

  final AnimatedMapController mapControllerImpl;

  SimpleMapController(this.mapControllerImpl);

  moveToPosition(double latitude, double longitude, {double? zoom}) {
    mapControllerImpl.animateTo(dest: LatLng(latitude, longitude), zoom: zoom ?? mapControllerImpl.zoom);
  }

  updateMarkers(List<MarkerData> list) {
    listMarker = list;
    notifyListeners();
  }
}