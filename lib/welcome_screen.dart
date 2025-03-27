import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:narad/camera_feed.dart';
import 'package:flutter/material.dart';
//import 'package:animated_text_kit/animated_text_kit.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin{
  late AnimationController controller;
  late Animation animation;

  @override
  void initState(){
    super.initState();
    controller = AnimationController(duration: Duration(seconds: 2), vsync: this);
    animation = ColorTween(begin: Colors.yellowAccent, end: Colors.white).animate(controller);
    controller.forward();
    controller.addListener((){
      setState(() {});
      print(animation.value);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Center(
                    child: Container(
                      child: Image.asset('images/narad2-removebg-preview.png'),
                      height: 50.0,
                    ),
                  ),
                ),
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'NARAD',
                      textStyle: TextStyle(
                        color: Colors.black54,
                        fontSize: 35.0,
                        fontWeight: FontWeight.w500,
                      ),
                      speed: const Duration(milliseconds: 500),
                    ),
                  ],
                  totalRepeatCount: 1,
                )
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Material(
                elevation: 5.0,
                color: Colors.yellowAccent,
                borderRadius: BorderRadius.circular(30.0),
                child: MaterialButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context){
                              return CameraBackground();
                            }
                        )
                    );//Go to login screen.
                  },
                  minWidth: 200.0,
                  height: 42.0,
                  child: Text(
                    'Directions',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}