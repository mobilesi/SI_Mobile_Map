import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

import 'marker_data.dart';

class SimpleMapController extends ChangeNotifier {

  List<MarkerData>? listMarker;

  final MapControllerImpl mapControllerImpl;

  SimpleMapController(this.mapControllerImpl);

  moveToPosition(double latitude, double longitude, {double zoom = 13.0}) {
    mapControllerImpl.move(LatLng(latitude, longitude), zoom);
  }

  updateMarkers(List<MarkerData> list) {
    listMarker = list;
    notifyListeners();
  }
}