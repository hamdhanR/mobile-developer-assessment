import 'package:flutter/material.dart';
import 'package:flutter_application_1/GameBoard.dart';

void main() {
  runApp(BalloonPopGame());
}

class BalloonPopGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  

  
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Pop-The-Balloon',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
      backgroundColor: Colors.purple,
    ),
    backgroundColor: Colors.purple[200],
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 250, // Adjust the height of the image as needed
            child: Image.asset(
              'assets/pngwing.png', // Replace 'your_image.png' with the actual path to your image asset
              fit: BoxFit.contain, // Adjust the fit as needed
            ),
          ),
          SizedBox(height: 20), // Adjust the spacing as needed
          Text(
            'Welcome to Pop-The-Balloon!',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20), // Adjust the spacing as needed
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),

              ),backgroundColor: Colors.purple,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GameBoard()),
              );
            },
            child: Text('Start',style: TextStyle(color: Colors.white),),
            
          ),
        ],
      ),
    ),
  );
}



}
