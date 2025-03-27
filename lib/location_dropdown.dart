import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

class LocationSearchField extends StatefulWidget {
  final Function(String, LatLng) onLocationSelected;
  final String hint;

  LocationSearchField({required this.onLocationSelected, required this.hint});

  @override
  _LocationSearchFieldState createState() => _LocationSearchFieldState();
}

class _LocationSearchFieldState extends State<LocationSearchField> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];
  bool isSwipeEnabled = false;
  String savedValue = ""; // Final-like variable for storing input
  //String savedValue2 = "";

  Future<void> _getLocationSuggestions(String query) async {
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
  }

  void checkFields() {
    setState(() {
      isSwipeEnabled = /*_controller1.text.isNotEmpty &&*/ _controller.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          /*decoration: InputDecoration(
            hintText: widget.hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            suffixIcon: Icon(Icons.location_on),
          ),*/
          decoration: InputDecoration(
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
            //suffixText: 'End',
            /*suffixStyle: TextStyle(
              fontSize: 25.0,
              color: Colors.white,
            ),*/
          ),
          onChanged: _getLocationSuggestions,
          onSubmitted: (value){
            setState(() {
              savedValue = _controller.text; // Save the user input
            });
            print("Saved Value of location: $savedValue");
          },
          /*onChanged: (value) {
            _getLocationSuggestions;
            setState(() {
              savedValue = _controller.text; // Save the user input
            });
            print("Saved Value of location: $savedValue");
          },// Fetch suggestions as user types*/
        ),
        _suggestions.isNotEmpty
            ? Container(
          height: 200,
          child: ListView.builder(
            itemCount: _suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = _suggestions[index];
              return ListTile(
                title: Text(suggestion["display_name"]),
                onTap: () {
                  LatLng location = LatLng(suggestion["lat"], suggestion["lon"]);
                  _controller.text = suggestion["display_name"];
                  setState(() => _suggestions = []);
                  widget.onLocationSelected(suggestion["display_name"], location);
                },
              );
            },
          ),
        )
            : SizedBox(),
      ],
    );
  }
}
