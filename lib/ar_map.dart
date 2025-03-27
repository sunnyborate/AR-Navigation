import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:vector_math/vector_math_64.dart';

/*void main() {
  runApp(MyApp());
}*/

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ARMapScreen(),
    );
  }
}

class ARMapScreen extends StatefulWidget {
  @override
  _ARMapScreenState createState() => _ARMapScreenState();
}

class _ARMapScreenState extends State<ARMapScreen> {
  late ArCoreController _arCoreController;
  Location location = Location();

  final List<Map<String, double>> routeCoordinates = [
    {'lat': 37.7749, 'lon': -122.4194},
    {'lat': 37.7750, 'lon': -122.4195},
    {'lat': 37.7751, 'lon': -122.4196}
  ];

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AR Route Map')),
      body: ArCoreView(
        onArCoreViewCreated: onArCoreViewCreated,
      ),
    );
  }

  void onArCoreViewCreated(ArCoreController controller) {
    _arCoreController = controller;
    placeModelsOnRoute();
  }

  void getCurrentLocation() async {
    var userLocation = await location.getLocation();
    print("User Location: ${userLocation.latitude}, ${userLocation.longitude}");
  }

  void placeModelsOnRoute() async {
    for (var coord in routeCoordinates) {
      Vector3 position = gpsToARPosition(coord['lat']!, coord['lon']!);
      _arCoreController.addArCoreNode(
        ArCoreReferenceNode(
          name: "RouteNode",
          objectUrl: "assets/model.glb",
          position: position,
        ),
      );
    }
  }

  Vector3 gpsToARPosition(double lat, double lon) {
    double baseLat = routeCoordinates.first['lat']!;
    double baseLon = routeCoordinates.first['lon']!;
    double scaleFactor = 1000;
    return Vector3((lat - baseLat) * scaleFactor, 0, (lon - baseLon) * scaleFactor);
  }

  void updateRemainingDistance(LatLng endLocation, Function(double) onUpdate) async {
    try {
      LocationData position = await location.getLocation();
      LatLng userLocation = LatLng(position.latitude!, position.longitude!);

      final distance = Location().distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        endLocation.latitude,
        endLocation.longitude,
      ) /
          1000; // Convert meters to kilometers

      onUpdate(distance);
    } catch (e) {
      print("Error getting location: $e");
    }
  }
}

extension on Location {
  distanceBetween(double latitude, double longitude, double latitude2, double longitude2) {}
}
