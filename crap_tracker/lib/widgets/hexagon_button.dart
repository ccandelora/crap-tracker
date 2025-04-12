import 'package:flutter/material.dart';
import 'dart:math' as math;

class HexagonButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double size;
  final Color? color;
  final Color? highlightColor;
  final bool isSelected;

  const HexagonButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.size = 60,
    this.color,
    this.highlightColor,
    this.isSelected = false,
  });

  @override
  State<HexagonButton> createState() => _HexagonButtonState();
}

class _HexagonButtonState extends State<HexagonButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDarkMode 
        ? const Color(0xFF1E1E1E) 
        : Colors.white;
    final defaultHighlightColor = Theme.of(context).colorScheme.primary;
    
    final buttonColor = widget.color ?? defaultColor;
    final highlightColor = widget.highlightColor ?? defaultHighlightColor;
    
    // Border color based on selection state and theme
    final borderColor = widget.isSelected 
        ? highlightColor
        : isDarkMode 
            ? Colors.grey.shade800 
            : Colors.grey.shade300;
            
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: CustomPaint(
              painter: HexagonPainter(
                color: buttonColor,
                borderColor: borderColor,
                highlighted: widget.isSelected,
                highlightColor: highlightColor,
                isPressed: _isPressed,
              ),
              child: SizedBox(
                width: widget.size,
                height: widget.size * 0.866, // Height of a hexagon is ~0.866 times its width
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class HexagonPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final bool highlighted;
  final Color highlightColor;
  final bool isPressed;

  HexagonPainter({
    required this.color,
    required this.borderColor,
    this.highlighted = false,
    required this.highlightColor,
    this.isPressed = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Radius is half the width of the hexagon
    final radius = size.width / 2;

    // Calculate the six points of the hexagon
    for (int i = 0; i < 6; i++) {
      // Each point is 60 degrees (π/3 radians) apart
      final angle = (i * math.pi / 3) - math.pi / 6; // Rotate to make flat tops
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    canvas.drawPath(
      path.shift(const Offset(0, 2)),
      shadowPaint,
    );

    // Create gradient for fill
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isPressed 
          ? [color.withOpacity(0.7), color.withOpacity(0.9)]
          : [color, color.withOpacity(0.8)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Fill the hexagon
    final fillPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, fillPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = highlighted ? highlightColor : borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = highlighted ? 2.0 : 1.0;
    
    canvas.drawPath(path, borderPaint);

    // Add inner highlight for selected state
    if (highlighted) {
      final highlightPaint = Paint()
        ..color = highlightColor.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
      final innerPath = Path();
      for (int i = 0; i < 6; i++) {
        final angle = (i * math.pi / 3) - math.pi / 6;
        final r = radius - 4; // Slightly smaller
        final x = centerX + r * math.cos(angle);
        final y = centerY + r * math.sin(angle);
        
        if (i == 0) {
          innerPath.moveTo(x, y);
        } else {
          innerPath.lineTo(x, y);
        }
      }
      innerPath.close();
      
      canvas.drawPath(innerPath, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant HexagonPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.highlighted != highlighted ||
        oldDelegate.isPressed != isPressed;
  }
} 