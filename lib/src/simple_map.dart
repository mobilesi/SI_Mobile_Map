import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:si_map/src/simple_map_controller.dart';

import 'marker_data.dart';

typedef ClusterWidgetBuilder = Widget Function(BuildContext context, int numberMarkersClustered);

class SimpleMap extends StatefulWidget {
  final List<MarkerData> markerData;
  final MarkerData center;
  final double zoom;
  final bool useCluster;
  final Size clusterSize;
  final ClusterWidgetBuilder? clusterWidgetBuilder;
  final Function? onReady;

  const SimpleMap(
      {super.key,
      required this.center,
      this.zoom = 13.0,
      this.markerData = const [],
      this.onReady,
      this.useCluster = false,
      this.clusterSize = const Size(40, 40),
      this.clusterWidgetBuilder});

  @override
  State<StatefulWidget> createState() {
    return _SimpleMapState();
  }
}

class _SimpleMapState extends State<SimpleMap> with TickerProviderStateMixin {
  late LatLng _current;

  // final MapControllerImpl mapControllerImpl = MapControllerImpl();

  late SimpleMapController _simpleMapController;

  final List<MarkerData> _markerData = [];
  final List<Marker> _markers = [];

  // final SuperclusterMutableController _superClusterController = SuperclusterMutableController();

  late final _mapController = AnimatedMapController(vsync: this);

  @override
  void initState() {
    _current = LatLng(widget.center.latitude, widget.center.longitude);
    _simpleMapController = SimpleMapController(_mapController)..listMarker = widget.markerData;
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
      // _superClusterController.replaceAll(_markerData
      //     .map((e) => _getMarker(e.label, e.assetName, LatLng(e.latitude, e.longitude),
      //     imageWidth: e.width, imageHeight: e.height, onTap: e.onTap))
      //     .toList());
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
              // color: Colors.white,
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
      mapController: _mapController,
      options: MapOptions(
        center: _current,
        zoom: widget.zoom,
        minZoom: 5.0,
        maxZoom: 18.0,
        interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        // onMapReady: () {
        //   widget.onReady?.call(SimpleMapController(mapControllerImpl));
        // }
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}",
          // urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          // userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          subdomains: const ["mt0", "mt1", "mt2", "mt3"],
          // minZoom: 10.0,
          // maxZoom: 18.5,
        ), !widget.useCluster ?
        MarkerLayer(
          markers: _markerData
              .map((e) => _getMarker(e.label, e.assetName, LatLng(e.latitude, e.longitude),
                  imageWidth: e.width, imageHeight: e.height, onTap: e.onTap))
              .toList(),
        ) :
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            maxClusterRadius: 120,
            size: widget.clusterSize,
            fitBoundsOptions: const FitBoundsOptions(
              padding: EdgeInsets.all(50),
            ),
            disableClusteringAtZoom: 16,
            // rotate: false,
            anchor: AnchorPos.align(AnchorAlign.center),
            markers: _markerData
                .map((e) => _getMarker(e.label, e.assetName, LatLng(e.latitude, e.longitude),
                    imageWidth: e.width, imageHeight: e.height, onTap: e.onTap))
                .toList(),
            showPolygon: false,
            centerMarkerOnClick: false,
            zoomToBoundsOnClick: false,
            spiderfyCluster: false,
            // circleSpiralSwitchover: 1,
            // polygonOptions: PolygonOptions(
            //     borderColor: Colors.blueAccent,
            //     color: Colors.black12,
            //     borderStrokeWidth: 3),
            builder: (context, markers) {
              if (widget.clusterWidgetBuilder == null) {
                return const SizedBox();
              }
              return widget.clusterWidgetBuilder!.call(context, markers.length);
            },
          ),
        )
        // SuperclusterLayer.mutable(
        //   initialMarkers: _markerData
        //       .map((e) => _getMarker(e.label, e.assetName, LatLng(e.latitude, e.longitude),
        //       imageWidth: e.width, imageHeight: e.height, onTap: e.onTap))
        //       .toList(),
        //   controller: _superClusterController,
        //   onMarkerTap: (marker) {
        //     // _superClusterController.remove(marker);
        //   },
        //   rotate: true,
        //   clusterWidgetSize: const Size(40, 40),
        //   anchor: AnchorPos.align(AnchorAlign.center),
        //   clusterZoomAnimation: const AnimationOptions.animate(
        //     curve: Curves.linear,
        //     velocity: 1,
        //   ),
        //   calculateAggregatedClusterData: true,
        //   builder: (context, position, markerCount, extraClusterData) {
        //     return Container(
        //       decoration: BoxDecoration(
        //           borderRadius: BorderRadius.circular(20.0),
        //           color: Colors.blue),
        //       child: Center(
        //         child: Text(
        //           markerCount.toString(),
        //           style: const TextStyle(color: Colors.white),
        //         ),
        //       ),
        //     );
        //   },
        // ),
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
