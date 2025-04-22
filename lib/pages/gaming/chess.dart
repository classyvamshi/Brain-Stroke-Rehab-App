import 'package:flutter/material.dart';
import 'dart:math';

// Chess piece representation (using Unicode for simplicity)
const Map<String, String> pieceSymbols = {
  'wk': '♔', // White King
  'wq': '♕', // White Queen
  'wr': '♖', // White Rook
  'wb': '♗', // White Bishop
  'wn': '♘', // White Knight
  'wp': '♙', // White Pawn
  'bk': '♚', // Black King
  'bq': '♛', // Black Queen
  'br': '♜', // Black Rook
  'bb': '♝', // Black Bishop
  'bn': '♞', // Black Knight
  'bp': '♟', // Black Pawn
  '': '', // Empty square
};

class ChessPage extends StatefulWidget {
  const ChessPage({super.key});

  @override
  State<ChessPage> createState() => _ChessPageState();
}

class _ChessPageState extends State<ChessPage> {
  late List<List<String>> board; // 8x8 board state
  String? selectedPiece; // Selected piece (e.g., 'wp' for white pawn)
  int? selectedRow;
  int? selectedCol;
  bool isWhiteTurn = true; // White starts

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  void _initializeBoard() {
    // Standard chess starting position
    board = [
      ['br', 'bn', 'bb', 'bq', 'bk', 'bb', 'bn', 'br'], // Black back rank
      ['bp', 'bp', 'bp', 'bp', 'bp', 'bp', 'bp', 'bp'], // Black pawns
      ['', '', '', '', '', '', '', ''], // Empty rows
      ['', '', '', '', '', '', '', ''],
      ['', '', '', '', '', '', '', ''],
      ['', '', '', '', '', '', '', ''],
      ['wp', 'wp', 'wp', 'wp', 'wp', 'wp', 'wp', 'wp'], // White pawns
      ['wr', 'wn', 'wb', 'wq', 'wk', 'wb', 'wn', 'wr'], // White back rank
    ];
  }

  void _selectSquare(int row, int col) {
    setState(() {
      if (selectedPiece == null) {
        // Select a piece if it's the player's turn and piece belongs to them
        if (board[row][col].isNotEmpty &&
            ((isWhiteTurn && board[row][col].startsWith('w')) ||
                (!isWhiteTurn && board[row][col].startsWith('b')))) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      } else {
        // Move piece if valid (simplified: just check if target is empty or opponent)
        if (_isValidMove(row, col)) {
          board[row][col] = selectedPiece!;
          board[selectedRow!][selectedCol!] = '';
          selectedPiece = null;
          selectedRow = null;
          selectedCol = null;

          // Switch turns and trigger computer move if black's turn
          isWhiteTurn = !isWhiteTurn;
          if (!isWhiteTurn) {
            _computerMove();
          }
        } else {
          // Deselect if invalid move
          selectedPiece = null;
          selectedRow = null;
          selectedCol = null;
        }
      }
    });
  }

  bool _isValidMove(int targetRow, int targetCol) {
    // Simplified validation: allow move if target is empty or opponent's piece
    if (targetRow == selectedRow && targetCol == selectedCol) return false;
    String target = board[targetRow][targetCol];
    if (target.isEmpty ||
        (isWhiteTurn && target.startsWith('b')) ||
        (!isWhiteTurn && target.startsWith('w'))) {
      return true; // For simplicity; add real chess rules here later
    }
    return false;
  }

  void _computerMove() {
    // Simple AI: Randomly move a black piece to a valid square
    List<Map<String, int>> blackPieces = [];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (board[r][c].startsWith('b')) {
          blackPieces.add({'row': r, 'col': c});
        }
      }
    }

    if (blackPieces.isEmpty) return; // No pieces left (unlikely)

    Random rand = Random();
    while (blackPieces.isNotEmpty) {
      int index = rand.nextInt(blackPieces.length);
      int fromRow = blackPieces[index]['row']!;
      int fromCol = blackPieces[index]['col']!;
      String piece = board[fromRow][fromCol];

      // Find valid moves (simplified: any empty or white piece square)
      List<Map<String, int>> validMoves = [];
      for (int r = 0; r < 8; r++) {
        for (int c = 0; c < 8; c++) {
          if (_isValidMoveForComputer(fromRow, fromCol, r, c)) {
            validMoves.add({'row': r, 'col': c});
          }
        }
      }

      if (validMoves.isNotEmpty) {
        int moveIndex = rand.nextInt(validMoves.length);
        int toRow = validMoves[moveIndex]['row']!;
        int toCol = validMoves[moveIndex]['col']!;

        setState(() {
          board[toRow][toCol] = piece;
          board[fromRow][fromCol] = '';
          isWhiteTurn = true; // Back to player's turn
        });
        break;
      } else {
        blackPieces.removeAt(index); // Try another piece if no valid moves
      }
    }
  }

  bool _isValidMoveForComputer(int fromRow, int fromCol, int toRow, int toCol) {
    if (fromRow == toRow && fromCol == toCol) return false;
    String target = board[toRow][toCol];
    return target.isEmpty || target.startsWith('w'); // Black can capture white
  }

  Future<bool> _onWillPop() async {
    // Show a confirmation dialog when the back button is pressed
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit the game?'),
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
        ) ??
        false; // If the dialog is dismissed, return false
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Handle back button press
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chess vs Computer', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.purple.withOpacity(0.8),
          elevation: 4,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isWhiteTurn ? 'Your Turn (White)' : 'Computer\'s Turn (Black)',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
                height: MediaQuery.of(context).size.width * 0.9, // Square board
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 64,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    int row = index ~/ 8;
                    int col = index % 8;
                    bool isLightSquare = (row + col) % 2 == 0;
                    Color squareColor = isLightSquare ? Colors.grey[300]! : Colors.brown[700]!;

                    return GestureDetector(
                      onTap: () => _selectSquare(row, col),
                      child: Container(
                        color: (selectedRow == row && selectedCol == col)
                            ? Colors.yellow.withOpacity(0.5)
                            : squareColor,
                        child: Center(
                          child: Text(
                            pieceSymbols[board[row][col]]!,
                            style: const TextStyle(fontSize: 36), // Larger font size
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}