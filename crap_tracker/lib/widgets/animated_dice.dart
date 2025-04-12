import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedDice extends StatefulWidget {
  final int value;
  final double size;
  
  const AnimatedDice({
    super.key,
    required this.value,
    this.size = 80,
  });

  @override
  State<AnimatedDice> createState() => _AnimatedDiceState();
}

class _AnimatedDiceState extends State<AnimatedDice> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _rotationAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(AnimatedDice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.reset();
      _controller.forward();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_rotationAnimation.value * math.pi)
            ..rotateY(_rotationAnimation.value * math.pi),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: _buildDiceFace(),
          ),
        );
      },
    );
  }
  
  Widget _buildDiceFace() {
    // Layout of dots based on dice value
    switch (widget.value) {
      case 1:
        return Center(child: _buildDot());
      case 2:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(alignment: Alignment.topRight, child: _buildDot()),
              Align(alignment: Alignment.bottomLeft, child: _buildDot()),
            ],
          ),
        );
      case 3:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(alignment: Alignment.topRight, child: _buildDot()),
              Center(child: _buildDot()),
              Align(alignment: Alignment.bottomLeft, child: _buildDot()),
            ],
          ),
        );
      case 4:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_buildDot(), _buildDot()],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_buildDot(), _buildDot()],
              ),
            ],
          ),
        );
      case 5:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_buildDot(), _buildDot()],
              ),
              Center(child: _buildDot()),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_buildDot(), _buildDot()],
              ),
            ],
          ),
        );
      case 6:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_buildDot(), _buildDot()],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_buildDot(), _buildDot()],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_buildDot(), _buildDot()],
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildDot() {
    return Container(
      width: widget.size * 0.15,
      height: widget.size * 0.15,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }
} 