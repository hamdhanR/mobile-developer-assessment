import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(GameBoard());
}

class GameBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int totalScore = 0;
  int balloonBurst = 0;
  int balloonMiss = 0;
  int hits = 0;
  int misses = 0;
  List<Balloon> balloons = [];
  late Timer timer;
  int timeLeft = 120; // 2 minutes in seconds
  late AudioCache audioCache; // Audio player

  @override
  void initState() {
    super.initState();
    audioCache = AudioCache();
    _startGame();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _startGame() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (timeLeft > 0) {
        setState(() {
          _addBalloon();
          timeLeft--; // Decrement time left
        });
      } else {
        t.cancel();
        _endGame();
      }
    });
  }

  void _endGame() {
    // Navigate to end screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EndScreen(
          totalScore: totalScore,
          balloonBurst: balloonBurst,
          balloonMiss: balloonMiss,
          hits: hits,
          misses: misses,
        ),
      ),
    );
  }

  void _addBalloon() {
    // List of balloon image paths
    List<String> balloonImages = [
      'assets/balloon1.png',
      'assets/balloon2.png',
      'assets/balloon3.png',
      'assets/balloon4.png',
      'assets/balloon5.png',
    ];

    // Select a random image path from the list
    String imagePath = balloonImages[Random().nextInt(balloonImages.length)];

    setState(() {
      balloons.add(Balloon(
        key: UniqueKey(),
        imagePath: imagePath,
        onTap: () {
          setState(() {
            balloonBurst++;
            hits++;
            totalScore += 2;
          });
          audioCache.play('pop_sound.mp3'); // Play audio effect
        },
        onMiss: () {
          setState(() {
            balloonMiss++;
            misses++;
            totalScore -= 1;
          });
        },
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Balloon Pop Game'),
      ),
      backgroundColor: Color.fromARGB(255, 85, 106, 137),
      body: Stack(
        children: [
          ...balloons,
          Positioned(
            top: 0,
            left: 170,
            right: 170,
            child: Container(
              height: 50,
              color: Colors.blue,
              child: Center(
                child: Text(
                  'Time Left: ${Duration(seconds: timeLeft).toString().substring(2, 7)}',
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20, color: Colors.black),
                ),
              ),
            ),
          ),
          Positioned(
            top: 5,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Score: $totalScore',
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color:Colors.white),
                ),
                Text(
                  'Balloon Popped: $balloonBurst',
                  style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold, color: Color.fromARGB(255, 179, 193, 53)),
                ),
                Text(
                  'Balloon Missed: $balloonMiss',
                  style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold, color: Color.fromARGB(255, 234, 161, 190)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Balloon extends StatefulWidget {
  final String imagePath;
  final VoidCallback onTap;
  final VoidCallback onMiss;

  Balloon({
    required Key key,
    required this.imagePath,
    required this.onTap,
    required this.onMiss,
  }) : super(key: key);

  @override
  _BalloonState createState() => _BalloonState();
}

class _BalloonState extends State<Balloon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Offset position;
  late double speed;
  bool popped = false;
  late Timer _moveTimer; // Timer for moving the balloon

  @override
  void initState() {
    super.initState();
    position = Offset(Random().nextDouble() * 400, 600);
    speed = Random().nextDouble() * 3 + 1;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          popped = true;
          widget.onTap();
        }
      });
    _startMoving(); // Start moving the balloon
  }

  void _startMoving() {
    _moveTimer = Timer.periodic(Duration(milliseconds: 50), (Timer t) {
      setState(() {
        position = Offset(position.dx, position.dy - speed);
        if (position.dy < -100) {
          t.cancel();
          if (!popped) {
            widget.onMiss(); // Deduct score only if the balloon wasn't popped
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _moveTimer.cancel(); // Cancel the timer when the state is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: () {
          if (!popped) {
            _controller.forward();
          }
        },
        child: Transform.scale(
          scale: _animation.value,
          child: Image.asset(
            widget.imagePath,
            width: 50,
            height: 100,
          ),
        ),
      ),
    );
  }
}

class EndScreen extends StatelessWidget {
  final int totalScore;
  final int balloonBurst;
  final int balloonMiss;
  final int hits;
  final int misses;

  EndScreen({
    required this.totalScore,
    required this.balloonBurst,
    required this.balloonMiss,
    required this.hits,
    required this.misses,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Over'),
      ),backgroundColor: Colors.purple[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Score: $totalScore',
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24),
            ),
            Text(
              'Balloon Popped: $balloonBurst',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Balloon Missed: $balloonMiss',
              style: TextStyle(fontSize: 20),
            ),
            // Text(
            //   'Hits: $hits',
            //   style: TextStyle(fontSize: 20),
            // ),
            // Text(
            //   'Misses: $misses',
            //   style: TextStyle(fontSize: 20),
            // ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameBoard()),
                );
              }, style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Colors.purple),
  ),
              child: Text('Play Again',style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
