import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:latlong2/latlong.dart';
import 'package:narad/welcome_screen.dart';
import 'package:narad/map_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

class CameraBackground extends StatefulWidget {
  final Function(String, LatLng) onLocationSelected;
  final String hint;

  CameraBackground({
    this.onLocationSelected = _defaultLocationHandler, // Default function
    this.hint = "Enter Location",
  });

  static void _defaultLocationHandler(String location, LatLng latLng) {
    print("Default location selected: $location at $latLng");
  }

  @override
  _CameraBackgroundState createState() => _CameraBackgroundState();
}

class _CameraBackgroundState extends State<CameraBackground> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  List<Map<String, dynamic>> _suggestionsStart = [];
  List<Map<String, dynamic>> _suggestionsEnd = [];
  LatLng? _startLocation;
  LatLng? _endLocation;
  String? _activeField; // Tracks the active TextField: "start" or "end"
  Position? _currentPosition;
  Timer? _locationTimer;
  Map<String, double>? _endLocation_;

  double _remainingDistance = 0.0; // Store remaining distance

  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        if (_endLocation != null) {
          _remainingDistance = _calculateDistance(
            position.latitude,
            position.longitude,
            _endLocation_!["lat"]!,
            _endLocation_!["lon"]!,
          );
        }
      });
    });
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371; // Earth’s radius in km
    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Returns distance in km
  }

  void _setEndLocation(Map<String, dynamic> place) {
    setState(() {
      _endLocation = {"lat": place["lat"], "lon": place["lon"]} as LatLng?;
      _startLocationUpdates(); // Start tracking distance
    });
  }

  void updateRemainingDistance(
    LatLng endLocation,
    Function(double) onUpdate,
  ) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      );

      // Convert user's current position to LatLng
      LatLng userLocation = LatLng(position.latitude, position.longitude);

      // Calculate remaining distance
      final distance =
          Geolocator.distanceBetween(
            userLocation.latitude,
            userLocation.longitude,
            endLocation.latitude,
            endLocation.longitude,
          ) /
          1000; // Convert meters to kilometers

      // Update the UI with the remaining distance
      onUpdate(distance);
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _getUserLocation(); // Get location when the widget loads

    // Listen for changes in both TextFields
    _controller1.addListener(checkFields);
    _controller2.addListener(checkFields);

    /*if (_endLocation != null) {  //Check for null before calling function
      updateRemainingDistance(_endLocation!, (distance) {
        setState(() {
          _remainingDistance = distance;
        });
      });
    }*/
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(
        _cameras![0], // Use the back camera
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {});
      }
    }
  }

  /*Future<void> _getLocationSuggestions(String query) async {
    if (query.isEmpty) return;

    final url = Uri.parse("https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5");

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _suggestions = data.map((place) {
          return {
            "display_name": place["display_name"],
            "lat": double.parse(place["lat"]),
            "lon": double.parse(place["lon"]),
          };
        }).toList();
      });
    }
  }*/
  // Did changes in the below function in PBL Lab //////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\
  Future<void> _getLocationSuggestions(String query, String field) async {
    if (query.isEmpty) return;
    //Fetch the user's current location
    Position? currentPosition;
    try {
      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print("Error fetching location: $e");
    }

    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5",
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        if (field == "start") {
          _suggestionsStart =
              data.map((place) {
                return {
                  "display_name": place["display_name"],
                  "lat": double.parse(place["lat"]),
                  "lon": double.parse(place["lon"]),
                };
              }).toList();
        } else {
          _suggestionsEnd =
              data.map((place) {
                return {
                  "display_name": place["display_name"],
                  "lat": double.parse(place["lat"]),
                  "lon": double.parse(place["lon"]),
                };
              }).toList();
        }
        _activeField = field; // Set active field
      });
      // Insert "My Location" at the top if GPS is available
      if (currentPosition != null) {
        _suggestionsStart.insert(0, {
          "display_name": "📍 My Location",
          "lat": currentPosition.latitude,
          "lon": currentPosition.longitude,
        });
        /*_suggestionsEnd.insert(0, {
          "display_name": "📍 My Location",
          "lat": currentPosition.latitude,
          "lon": currentPosition.longitude,
        });*/
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  bool firstSwiped = false;
  bool isElementPresent = false;
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  String savedValue1 = ""; // Final-like variable for storing input
  String savedValue2 = "";
  bool isSwipeEnabled = false;

  // Function to check if both fields are filled
  void checkFields() {
    setState(() {
      isSwipeEnabled =
          _controller1.text.isNotEmpty && _controller2.text.isNotEmpty;
    });
  }

  // Function to update start location
  void _updateStartLocation(String location, LatLng latLng) {
    setState(() {
      _startLocation = latLng;
      _controller1.text = location;
      _suggestionsStart = [];
    });
  }

  // Function to update end location
  void _updateEndLocation(String location, LatLng latLng) {
    setState(() {
      _endLocation = latLng;
      _controller2.text = location;
      _suggestionsEnd = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Background
          _cameraController != null && _cameraController!.value.isInitialized
              ? CameraPreview(_cameraController!)
              : Container(color: Colors.black), // Placeholder
          // UI Overlay (example)
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  /*LocationSearchField(
                    hint: "Enter Start Location",
                    onLocationSelected: (String location, LatLng latLng) {
                      setState(() => _startLocation = latLng,);
                    },
                  ),*/
                  TextField(
                    controller: _controller1,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      icon: Icon(
                        Icons.location_city_outlined,
                        color: Colors.white,
                      ),
                      hintText: widget.hint,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 20.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.yellowAccent,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      focusColor: Colors.black54,
                      suffixText: 'Start',
                      suffixStyle: TextStyle(
                        fontSize: 25.0,
                        color: Colors.yellow.shade700,
                      ),
                    ),
                    //onChanged: _getLocationSuggestions(value,"start"),
                    onChanged: (value) {
                      _getLocationSuggestions(value, "start");
                    },

                    onSubmitted: (value) {
                      setState(() {
                        savedValue1 = _controller1.text; // Save the user input
                      });
                      print("Saved Value of start: $savedValue1");
                    },
                  ),
                  _suggestionsStart.isNotEmpty
                      ? Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            10,
                          ), // Rounded corners
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 5),
                          ], // Drop shadow
                        ),
                        child: ListView.builder(
                          itemCount: _suggestionsStart.length,
                          itemBuilder: (context, index) {
                            final suggestion = _suggestionsStart[index];
                            return ListTile(
                              title: Text(suggestion["display_name"]),
                              onTap: () {
                                LatLng location = LatLng(
                                  suggestion["lat"],
                                  suggestion["lon"],
                                );
                                _updateStartLocation(
                                  suggestion["display_name"],
                                  location,
                                );
                                _controller1.text = suggestion["display_name"];
                                setState(() => _suggestionsStart = []);
                                widget.onLocationSelected(
                                  suggestion["display_name"],
                                  location,
                                );
                              },
                            );
                          },
                        ),
                      )
                      : SizedBox(height: 5.0),
                  /*LocationSearchField(
                    hint: "Enter End Location",
                    onLocationSelected: (String location, LatLng latLng) {
                      setState(() => _endLocation = latLng);
                    },
                  ),*/
                  TextField(
                    controller: _controller2,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      icon: Icon(Icons.location_on_sharp, color: Colors.white),
                      hintText: widget.hint,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 20.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.yellowAccent,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      focusColor: Colors.black54,
                      suffixText: 'End',
                      suffixStyle: TextStyle(
                        fontSize: 25.0,
                        color: Colors.yellow.shade700,
                      ),
                    ),
                    //onChanged: _getLocationSuggestions,
                    onChanged: (value) {
                      _getLocationSuggestions(value, "end");
                    },

                    onSubmitted: (value) {
                      setState(() {
                        savedValue1 = _controller1.text; // Save the user input
                      });
                      print("Saved Value of end: $savedValue1");
                    },
                  ),
                  _suggestionsEnd.isNotEmpty
                      ? Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            10,
                          ), // Rounded corners
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 5),
                          ], // Drop shadow
                        ),

                        child: ListView.builder(
                          itemCount: _suggestionsEnd.length,
                          itemBuilder: (context, index) {
                            final suggestion = _suggestionsEnd[index];
                            return ListTile(
                              title: Text(suggestion["display_name"]),
                              onTap: () {
                                LatLng location = LatLng(
                                  suggestion["lat"],
                                  suggestion["lon"],
                                );
                                _updateEndLocation(
                                  suggestion["display_name"],
                                  location,
                                );
                                _controller2.text = suggestion["display_name"];
                                setState(() => _suggestionsEnd = []);
                                widget.onLocationSelected(
                                  suggestion["display_name"],
                                  location,
                                );
                              },
                            );
                          },
                        ),
                      )
                      : SizedBox(height: 10.0),
                  if (isElementPresent)
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  height: 75.0,
                                  padding: EdgeInsets.all(5.0),
                                  margin: EdgeInsets.all(3.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    backgroundBlendMode: BlendMode.plus,
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 5.0),
                                      Icon(Icons.turn_right, size: 50.0),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '500 m',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.yellow,
                                              ),
                                            ),
                                            Text(
                                              'Turn Right',
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Did changes to the below container today at PBL \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
                                Container(
                                  height: 75.0,
                                  padding: EdgeInsets.all(5.0),
                                  margin: EdgeInsets.all(3.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    backgroundBlendMode: BlendMode.lighten,
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        /*_remainingDistance > 0 ?*/"${_remainingDistance.toStringAsFixed(2)} km",// : "Calculating...",
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          color: Colors.yellow,
                                        ),
                                      ),
                                      SizedBox(width: double.infinity),
                                      Text(
                                        'remain',
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(bottom: 383),
                              alignment: Alignment.center,
                              height: 152.0,
                              padding: EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                backgroundBlendMode: BlendMode.plus,
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              child: MapWidget(
                                startLocation: _startLocation,
                                endLocation: _endLocation,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  //SizedBox(height: 90.0),
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Second Swipe Button (Initially Hidden)
                      if (firstSwiped)
                        SwipeButton.expand(
                          height: 65.0,
                          thumb: Icon(
                            Icons.double_arrow_rounded,
                            color: Colors.black54,
                          ),
                          child: Text(
                            "End Ride",
                            style: TextStyle(
                              color: Colors.yellowAccent,
                              fontSize: 20.0,
                            ),
                          ),
                          activeThumbColor: Colors.yellowAccent,
                          activeTrackColor: Colors.white70,
                          onSwipe: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Center(child: Text("Ride Ended!")),
                                backgroundColor: Colors.red.shade600,
                              ),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return WelcomeScreen();
                                },
                              ),
                            ); //Restart Operations*/
                          },
                        ),

                      // First Swipe Button (Visible Initially)
                      if (!firstSwiped)
                        IgnorePointer(
                          ignoring:
                              !isSwipeEnabled, // Disable interaction when false
                          child: Opacity(
                            opacity:
                                isSwipeEnabled
                                    ? 1.0
                                    : 0.5, // Show faded effect when disabled
                            child: SwipeButton.expand(
                              height: 65.0,
                              thumb: Icon(
                                Icons.double_arrow_rounded,
                                color: Colors.black54,
                              ),
                              child: Text(
                                "Start Ride",
                                style: TextStyle(
                                  color: Colors.yellowAccent,
                                  fontSize: 20.0,
                                ),
                              ),
                              activeThumbColor: Colors.yellowAccent,
                              activeTrackColor: Colors.white70,
                              onSwipe: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Center(
                                      child: Text("Ride Started!"),
                                    ),
                                    backgroundColor: Colors.green.shade600,
                                  ),
                                );
                                setState(() {
                                  firstSwiped = true; // Show the second button
                                  isElementPresent = true;
                                });
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
