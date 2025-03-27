import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapWidget extends StatefulWidget {
  final LatLng? startLocation;
  final LatLng? endLocation;

  const MapWidget({this.startLocation, this.endLocation});

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  List<LatLng> _routePoints = [];
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.startLocation != null) {
        _mapController.move(widget.startLocation!, 13.0);
      }
    });
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startLocation != null && widget.endLocation != null) {
      _fetchRoute(widget.startLocation!, widget.endLocation!);
      _mapController.move(widget.startLocation!, 13.0); // Move the map to start location
    }
  }

  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(
        "https://routing.openstreetmap.de/routed-foot/route/v1/driving/"
            "${start.longitude},${start.latitude};${end.longitude},${end.latitude}"
            "?overview=full&geometries=geojson");

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];

      setState(() {
        _routePoints = coordinates.map((point) => LatLng(point[1], point[0])).toList();
      });

      // Move the map to focus on the route
      _mapController.move(start, 13.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300, // Increased height for better visibility
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        //boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      clipBehavior: Clip.hardEdge,
      child: FlutterMap(
        mapController: _mapController, // Use the map controller
        options: MapOptions(
          initialCenter: widget.startLocation ?? LatLng(0, 0),
          initialZoom: 10.0,
        ),
        children: [
          TileLayer(urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"),
          if (_routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(points: _routePoints, strokeWidth: 4.0, color: Colors.blue),
              ],
            ),
          if (widget.startLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: widget.startLocation!,
                  width: 40,
                  height: 40,
                  child: Icon(Icons.location_on, color: Colors.yellow, size: 40),
                ),
                if (widget.endLocation != null)
                  Marker(
                    point: widget.endLocation!,
                    width: 40,
                    height: 40,
                    child: Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}


