import 'dart:math';
import 'package:flutter/material.dart';

class SnakeAndLadderPage extends StatefulWidget {
  const SnakeAndLadderPage({super.key});

  @override
  State<SnakeAndLadderPage> createState() => _SnakeAndLadderPageState();
}

class _SnakeAndLadderPageState extends State<SnakeAndLadderPage> {
  Color ply1Color = Colors.amberAccent;
  Color ply2Color = Colors.greenAccent;
  int randomNo = 1;
  bool toAnimate = false;
  int ply1 = 0, ply2 = 0;
  bool plyTurn = true;
  bool isComputer = false;

  int order(int n) {
    if (n <= 10) return 11 - n;
    if (n <= 30 && n > 20) return 31 - n + 20;
    if (n <= 50 && n > 40) return 51 - n + 40;
    if (n <= 70 && n > 60) return 71 - n + 60;
    if (n <= 90 && n > 80) return 91 - n + 80;
    return n;
  }

  int snakeLadderCmd(int ply) {
    switch (ply) {
      // Snakes
      case 99:
        ply = 66;
        break;
      case 95:
        ply = 72;
        break;
      case 79:
        ply = 49;
        break;
      case 63:
        ply = 41;
        break;
      case 56:
        ply = 36;
        break;
      case 44:
        ply = 33;
        break;
      case 37:
        ply = 30;
        break;
      case 25:
        ply = 16;
        break;
      case 21:
        ply = 3;
        break;
      case 18:
        ply = 7;
        break;
      // Ladders
      case 5:
        ply = 14;
        break;
      case 20:
        ply = 29;
        break;
      case 23:
        ply = 45;
        break;
      case 40:
        ply = 48;
        break;
      case 42:
        ply = 53;
        break;
      case 58:
        ply = 67;
        break;
      case 70:
        ply = 90;
        break;
      case 71:
        ply = 92;
        break;
      case 75:
        ply = 97;
        break;
      default:
        break;
    }
    return ply;
  }

  int snakeLadderCmd2(int ply) {
    switch (ply) {
      // Snakes
      case 17:
        ply = 6;
        break;
      case 33:
        ply = 14;
        break;
      case 39:
        ply = 28;
        break;
      case 54:
        ply = 46;
        break;
      case 81:
        ply = 43;
        break;
      case 99:
        ply = 18;
        break;
      // Ladders
      case 84:
        ply = 95;
        break;
      case 47:
        ply = 86;
        break;
      case 50:
        ply = 59;
        break;
      case 2:
        ply = 43;
        break;
      default:
        break;
    }
    return ply;
  }

  void rollDice() {
    var randomizer = Random();
    setState(() {
      toAnimate = true;
      Future.delayed(const Duration(seconds: 1)).whenComplete(() {
        setState(() {
          randomNo = randomizer.nextInt(6) + 1;
          print(randomNo);
          toAnimate = false;
          if (plyTurn) {
            if (ply1 == 0) {
              if (randomNo == 1) ply1 = order(randomNo);
            } else if (ply1 + randomNo <= 100) {
              ply1 = order(order(ply1) + randomNo);
            }
            Future.delayed(const Duration(seconds: 1)).whenComplete(() {
              setState(() {
                ply1 = snakeLadderCmd(ply1); // Use first board configuration
                if (ply1 == 100) {
                  _showWinDialog(context, 'Player 1');
                }
              });
            });
          } else {
            if (ply2 == 0) {
              if (randomNo == 1) ply2 = order(randomNo);
            } else if (ply2 + randomNo <= 100) {
              ply2 = order(order(ply2) + randomNo);
            }
            Future.delayed(const Duration(seconds: 1)).whenComplete(() {
              setState(() {
                ply2 = snakeLadderCmd(ply2); // Use first board configuration
                if (ply2 == 100) {
                  _showWinDialog(context, 'Player 2');
                }
              });
            });
          }
          Future.delayed(const Duration(milliseconds: 1500)).whenComplete(() {
            setState(() {
              plyTurn = !plyTurn;
            });
          });
        });
      });
    });
  }

  void _showWinDialog(BuildContext context, String winner) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Snakes & Ladders"),
            content: Text('$winner WON !!!\nDo you want to Restart?'),
            actions: [
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  setState(() {
                    ply1 = 0;
                    ply2 = 0;
                    plyTurn = true;
                  });
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
    );
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Are you sure?'),
                content: const Text('Do you want to exit the game?'),
                actions: [
                  TextButton(
                    onPressed:
                        () => Navigator.of(
                          context,
                        ).pop(false), // No, stay in the game
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed:
                        () => Navigator.of(
                          context,
                        ).pop(true), // Yes, exit the game
                    child: const Text('Yes'),
                  ),
                ],
              ),
        ) ??
        false; // Default to false if dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitConfirmationDialog(context);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              final shouldExit = await _showExitConfirmationDialog(context);
              if (shouldExit) {
                Navigator.pop(context); // Navigate back to GamingPage
              }
            }, // Show confirmation before navigating back
          ),
          title: const Text('Snakes & Ladders'),
          backgroundColor: Colors.redAccent.withOpacity(0.8), // Match app theme
          automaticallyImplyLeading: false, // Explicitly control leading icon
          actions: [
            IconButton(
              icon: Icon(isComputer ? Icons.people_outline : Icons.computer),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: const Text("Snakes & Ladders"),
                        content: Text(
                          isComputer
                              ? "Would you like to change Player 1 to manual"
                              : "Would you like to convert Player 1 to Computer",
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Yes'),
                            onPressed: () {
                              setState(() {
                                isComputer = !isComputer;
                                plyTurn = true;
                                print('isComputer = $isComputer');
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('No'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: const Text("Snakes & Ladders"),
                        content: const Text("Would you like to Restart?"),
                        actions: [
                          TextButton(
                            child: const Text('Yes'),
                            onPressed: () {
                              setState(() {
                                ply1 = 0;
                                ply2 = 0;
                                plyTurn = true;
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('No'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                );
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              plyTurn
                  ? SizedBox(
                    height: 100,
                    width: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.person, color: ply1Color),
                        Text(
                          isComputer ? 'Computer' : 'Player 1',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                  : SizedBox(
                    height: 100,
                    width: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.person, color: ply2Color),
                        const Text('Player 2', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
              Expanded(
                flex: 2,
                child: Container(
                  height:
                      MediaQuery.of(context).size.width > 500
                          ? 500
                          : MediaQuery.of(context).size.width,
                  width:
                      MediaQuery.of(context).size.width > 500
                          ? 500
                          : MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        GridView.count(
                          crossAxisCount: 10,
                          padding: const EdgeInsets.all(2),
                          children: List.generate(100, (index) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              margin: EdgeInsets.zero,
                              color:
                                  ply1 == 100 - index || ply2 == 100 - index
                                      ? Colors.white
                                      : (index >= 10 && index <= 19) ||
                                          (index >= 30 && index <= 39) ||
                                          (index >= 50 && index <= 59) ||
                                          (index >= 70 && index <= 79) ||
                                          (index >= 90 && index <= 99)
                                      ? index.isOdd
                                          ? const Color.fromRGBO(
                                            220,
                                            200,
                                            109,
                                            1,
                                          )
                                          : const Color.fromRGBO(39, 25, 60, 1)
                                      : index.isEven
                                      ? const Color.fromRGBO(220, 200, 109, 1)
                                      : const Color.fromRGBO(39, 25, 60, 1),
                              child: Text(
                                ' ${order(100 - index)}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }),
                        ),
                        GridView.count(
                          crossAxisCount: 10,
                          padding: const EdgeInsets.all(2),
                          children: List.generate(100, (index) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              margin: EdgeInsets.zero,
                              color: Colors.transparent,
                              child: Center(
                                child:
                                    ply1 == 100 - index
                                        ? Icon(
                                          Icons.person,
                                          color: ply1Color,
                                          size: 20,
                                        )
                                        : ply2 == 100 - index
                                        ? Icon(
                                          Icons.person,
                                          color: ply2Color,
                                          size: 20,
                                        )
                                        : const SizedBox(),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: rollDice,
                  child: const Text('Roll Dice'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Get 1 to start the game for a player'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
