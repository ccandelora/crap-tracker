import 'package:flutter/material.dart';
import 'package:crap_tracker/widgets/dice_widget.dart';

class DiceInputWidget extends StatefulWidget {
  final Function(int diceOne, int diceTwo) onDiceRolled;

  const DiceInputWidget({
    Key? key,
    required this.onDiceRolled,
  }) : super(key: key);

  @override
  State<DiceInputWidget> createState() => _DiceInputWidgetState();
}

class _DiceInputWidgetState extends State<DiceInputWidget> {
  int? _diceOne;
  int? _diceTwo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDiceSelection(1),
            const SizedBox(width: 20),
            _buildDiceSelection(2),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _canSubmit() ? _submitRoll : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          ),
          child: const Text(
            'Record Roll',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildDiceSelection(int diceNumber) {
    return Column(
      children: [
        Text(
          'Dice ${diceNumber}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          width: 140,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              if (diceNumber == 1 && _diceOne != null ||
                  diceNumber == 2 && _diceTwo != null)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: DiceWidget(
                    value: diceNumber == 1 ? _diceOne! : _diceTwo!,
                    size: 60,
                  ),
                ),
              Wrap(
                alignment: WrapAlignment.center,
                children: List.generate(
                  6,
                  (index) => Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: _buildDiceValueButton(
                      index + 1,
                      diceNumber == 1
                          ? _diceOne == index + 1
                          : _diceTwo == index + 1,
                      () => _selectDiceValue(diceNumber, index + 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiceValueButton(int value, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  void _selectDiceValue(int diceNumber, int value) {
    setState(() {
      if (diceNumber == 1) {
        _diceOne = value;
      } else {
        _diceTwo = value;
      }
    });
  }

  bool _canSubmit() {
    return _diceOne != null && _diceTwo != null;
  }

  void _submitRoll() {
    if (_diceOne != null && _diceTwo != null) {
      widget.onDiceRolled(_diceOne!, _diceTwo!);
      // Reset after submitting
      setState(() {
        _diceOne = null;
        _diceTwo = null;
      });
    }
  }
} 