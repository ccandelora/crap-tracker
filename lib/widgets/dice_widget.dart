import 'package:flutter/material.dart';

class DiceWidget extends StatelessWidget {
  final int value;
  final double size;
  final Color color;
  final Color dotColor;

  const DiceWidget({
    Key? key,
    required this.value,
    this.size = 80.0,
    this.color = Colors.white,
    this.dotColor = Colors.black,
  })  : assert(value >= 1 && value <= 6, 'Dice value must be between 1 and 6'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildDiceFace(),
    );
  }

  Widget _buildDiceFace() {
    switch (value) {
      case 1:
        return _buildDots([
          const Offset(0.5, 0.5),
        ]);
      case 2:
        return _buildDots([
          const Offset(0.25, 0.25),
          const Offset(0.75, 0.75),
        ]);
      case 3:
        return _buildDots([
          const Offset(0.25, 0.25),
          const Offset(0.5, 0.5),
          const Offset(0.75, 0.75),
        ]);
      case 4:
        return _buildDots([
          const Offset(0.25, 0.25),
          const Offset(0.25, 0.75),
          const Offset(0.75, 0.25),
          const Offset(0.75, 0.75),
        ]);
      case 5:
        return _buildDots([
          const Offset(0.25, 0.25),
          const Offset(0.25, 0.75),
          const Offset(0.5, 0.5),
          const Offset(0.75, 0.25),
          const Offset(0.75, 0.75),
        ]);
      case 6:
        return _buildDots([
          const Offset(0.25, 0.25),
          const Offset(0.25, 0.5),
          const Offset(0.25, 0.75),
          const Offset(0.75, 0.25),
          const Offset(0.75, 0.5),
          const Offset(0.75, 0.75),
        ]);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDots(List<Offset> positions) {
    return Stack(
      children: positions
          .map(
            (position) => Positioned(
              left: position.dx * size,
              top: position.dy * size,
              child: Container(
                width: size * 0.15,
                height: size * 0.15,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class DiceRollWidget extends StatelessWidget {
  final int diceOne;
  final int diceTwo;
  final double diceSize;

  const DiceRollWidget({
    Key? key,
    required this.diceOne,
    required this.diceTwo,
    this.diceSize = 80.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DiceWidget(value: diceOne, size: diceSize),
        const SizedBox(width: 20),
        DiceWidget(value: diceTwo, size: diceSize),
      ],
    );
  }
} 