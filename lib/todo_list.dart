// Stuff to do til 28/03/25

/*
1. AR Map functionality
2. Responsive text fields for locations ----------done
3. Mini directions and distance-left widget integration.
4. Custom mini map integration-----------------done
5. UI upgrade-------------------done
6. Testing/debugging (atleast 2 days before the exhibition)
7. Add a 'current location' option under suggestions dropdown in text fields.
8.create 3D plane object for AR map integration


// FINAL DEADLINE OF PROJECT 26/03/25

TextField( ////////////////////////////TEXT FIELD 1
                    controller: _controller1,
                    onChanged: (value) {
                      setState(() {
                        savedValue1 = _controller1.text; // Save the user input
                      });
                      print("Saved Value of Start: $savedValue1");
                    },
                    decoration: InputDecoration(
                      //fillColor: Colors.white,
                      //filled: true,
                      icon: Icon(Icons.not_started, color: Colors.white),
                      hintText: 'Start Location',
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
                        color: Colors.white,
                      ),
                    ),
                  ),

                  TextField( ///////////////////////////////TEXT FIELD 2
                    controller: _controller2,
                    onChanged: (value) {
                      setState(() {
                        savedValue2 = _controller2.text; // Save the user input
                      });
                      print("Saved Value of End: $savedValue2");
                    },
                    decoration: InputDecoration(
                      icon: Icon(Icons.location_on_sharp, color: Colors.white),
                      hintText: 'End Location',
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
                        color: Colors.white,
                      ),
                    ),
                  ),

                  https://mbjlpponfxddgoimecsx.su
 */