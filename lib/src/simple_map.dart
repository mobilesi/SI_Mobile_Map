import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:si_map/src/simple_map_controller.dart';

import 'marker_data.dart';

class SimpleMap extends StatefulWidget {
  final List<MarkerData> markerData;
  final MarkerData center;
  final double zoom;
  final Function? onReady;

  const SimpleMap(
      {super.key, required this.center, this.zoom = 13.0, this.markerData = const [], this.onReady});

  @override
  State<StatefulWidget> createState() {
    return _SimpleMapState();
  }
}

class _SimpleMapState extends State<SimpleMap> {
  late LatLng _current;

  final MapControllerImpl mapControllerImpl = MapControllerImpl();

  late SimpleMapController _simpleMapController;

  List<MarkerData> _markerData = [];

  @override
  void initState() {
    _current = LatLng(widget.center.latitude, widget.center.longitude);
    _simpleMapController = SimpleMapController(mapControllerImpl)..listMarker = widget.markerData;
    _markerData.addAll(widget.markerData);
    _simpleMapController.addListener(_handleListener);
    widget.onReady?.call(_simpleMapController);
    super.initState();
  }

  _handleListener() {
    if (_simpleMapController.listMarker == null) {
      return;
    }
    setState(() {
      _markerData.clear();
      _markerData.addAll(_simpleMapController.listMarker!);
    });
  }

  @override
  void dispose() {
    _simpleMapController.removeListener(_handleListener);
    super.dispose();
  }

  Marker _getMarker(String label, String imageName, LatLng latLng,
      {double imageWidth = 16, double imageHeight = 16, bool centerIcon = false, Function? onTap}) {
    return Marker(
      width: 150,
      height: ((label.isNotEmpty ? 20 : 0) + imageHeight) * 2 - (centerIcon ? imageHeight : 0),
      point: latLng,
      builder: (ctx) => InkWell(
        onTap: () {
          onTap?.call(latLng.latitude, latLng.longitude);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              color: Colors.white,
              height: label.isNotEmpty ? 20 : 0,
              child: Text(
                label,
                style: const TextStyle(fontSize: 16, height: 20 / 16, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
            imageName.isEmpty
                ? const SizedBox()
                : Container(
                    alignment: Alignment.center,
                    width: imageWidth,
                    height: imageHeight,
                    decoration: BoxDecoration(image: DecorationImage(image: AssetImage(imageName), fit: BoxFit.fill)),
                    // child: AppText(e.vehicles!.length.toString(), color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600,),
                  )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapControllerImpl,
      options: MapOptions(
        center: _current,
        zoom: widget.zoom,
        interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        // onMapReady: () {
        //   widget.onReady?.call(SimpleMapController(mapControllerImpl));
        // }
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}",
          // userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          subdomains: const ["mt0", "mt1", "mt2", "mt3"],
        ),
        MarkerLayer(
          markers: _markerData
              .map((e) => _getMarker(e.label, e.assetName, LatLng(e.latitude, e.longitude),
                  imageWidth: e.width, imageHeight: e.height, onTap: e.onTap))
              .toList(),
        )
      ],
      // options: MapOptions(
      //   center: _current,
      //   zoom: 15,
      //   interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
      // ),
      // layers: [
      //   TileLayerOptions(
      //       urlTemplate: "https://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}",
      //       subdomains: ["mt0", "mt1", "mt2", "mt3"],
      //       maxZoom: 20,
      //       minZoom: 6),
      //   PolygonLayerOptions(polygons: _polygons!),
      //   MarkerLayerOptions(markers: _markers)
      // ],
    );
  }
}
