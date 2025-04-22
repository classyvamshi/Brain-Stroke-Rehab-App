import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart'; 
import 'dart:async';


// Helper functions
List<String> imageSource() {
  return [
    'lib/images/image_1.png',
    'lib/images/image_2.png',
    'lib/images/image_3.png',
    'lib/images/image_4.png',
    'lib/images/image_5.png',
    'lib/images/image_6.png',
    'lib/images/image_7.png',
    'lib/images/image_8.png',
    'lib/images/image_1.png',
    'lib/images/image_2.png',
    'lib/images/image_3.png',
    'lib/images/image_4.png',
    'lib/images/image_5.png',
    'lib/images/image_6.png',
    'lib/images/image_7.png',
    'lib/images/image_8.png',
  ];
}

List createShuffledListFromImageSource() {
  List shuffledImages = List.from(imageSource());
  shuffledImages.shuffle();
  return shuffledImages;
}

List<bool> getInitialItemStateList() {
  return List.generate(16, (_) => true);
}

List<GlobalKey<FlipCardState>> createFlipCardStateKeysList() {
  return List.generate(16, (_) => GlobalKey<FlipCardState>());
}

class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key});

  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  int _previousIndex = -1;
  int _time = 3; // Countdown timer
  int _gameDuration = 0; // Game duration in seconds
  bool _flip = false;
  bool _start = false;
  bool _wait = false;
  late bool _isFinished;
  late Timer _timer; // Countdown timer
  late Timer _durationTimer; // Game duration timer
  late int _left;
  late List _data;
  late List<bool> _cardFlips;
  late List<GlobalKey<FlipCardState>> _cardStateKeys;

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          if (_time > 0) _time--;
        });
      }
    });
  }

  void startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted && _start && !_isFinished) {
        setState(() {
          _gameDuration++;
        });
      }
    });
  }

  void startGameAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _start = true;
          _timer.cancel();
          startDurationTimer(); // Start duration timer when game begins
        });
      }
    });
  }

  void initializeGameData() {
    _data = createShuffledListFromImageSource();
    _cardFlips = getInitialItemStateList();
    _cardStateKeys = createFlipCardStateKeysList();
    _time = 3;
    _left = (_data.length ~/ 2);
    _isFinished = false;
    _gameDuration = 0; // Reset duration on game start
  }

  void resetGame() {
    setState(() {
      initializeGameData();
      startTimer();
      startGameAfterDelay();
    });
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('You completed the game in $_gameDuration seconds!\nDo you want to play another game?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to GamingPage
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              resetGame(); // Start a new game
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initializeGameData();
    startTimer();
    startGameAfterDelay();
  }

  @override
  void dispose() {
    _timer.cancel();
    _durationTimer.cancel(); // Clean up duration timer
    super.dispose();
  }

  Widget getItem(int index) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_data[index]),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            debugPrint('Error loading image ${_data[index]}: $exception');
          },
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: _data[index] == null ? const Icon(Icons.error) : null,
    );
  }

  Future<bool> _onWillPop() async {
    if (_isFinished) return true; // Allow exit if game is finished
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Game'),
            content: const Text('Are you sure you want to exit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // No
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Yes
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false; // Default to false if dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return WillPopScope(
      onWillPop: _onWillPop, // Handle back button
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Memory Game', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue.withOpacity(0.8),
          elevation: 4,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Remaining: $_left', style: theme.bodyMedium),
                      Text('Duration: ${_start ? _gameDuration : 0}s', style: theme.bodyMedium),
                      Text('Countdown: $_time', style: theme.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                GridView.builder(
                  padding: const EdgeInsets.all(8),
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _data.length,
                  itemBuilder: (context, index) => _start
                      ? FlipCard(
                          key: _cardStateKeys[index],
                          onFlip: () {
                            if (_wait || !_cardFlips[index]) return;
                            if (!_flip) {
                              _flip = true;
                              _previousIndex = index;
                            } else {
                              _flip = false;
                              if (_previousIndex != index) {
                                if (_data[_previousIndex] != _data[index]) {
                                  _wait = true;
                                  Future.delayed(const Duration(milliseconds: 1500), () {
                                    if (mounted) {
                                      final prevState = _cardStateKeys[_previousIndex].currentState;
                                      final currentState = _cardStateKeys[index].currentState;
                                      if (prevState != null && currentState != null) {
                                        prevState.toggleCard();
                                        currentState.toggleCard();
                                      } else {
                                        debugPrint('Error: FlipCardState is null at index $_previousIndex or $index');
                                      }
                                      _wait = false;
                                      setState(() {});
                                    }
                                  });
                                } else {
                                  _cardFlips[_previousIndex] = false;
                                  _cardFlips[index] = false;
                                  _left--;
                                  if (_left == 0) {
                                    _isFinished = true;
                                    _start = false;
                                    _durationTimer.cancel(); // Stop timer when game ends
                                    showGameOverDialog(); // Show dialog when game finishes
                                  }
                                }
                              }
                            }
                            setState(() {});
                          },
                          flipOnTouch: _wait ? false : _cardFlips[index],
                          direction: FlipDirection.HORIZONTAL,
                          front: Container(
                            margin: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              image: const DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage("lib/images/image_cover.jpg"),
                              ),
                            ),
                          ),
                          back: getItem(index),
                        )
                      : getItem(index),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}