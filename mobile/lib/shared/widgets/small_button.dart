import 'package:flutter/material.dart';

class SmallButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  const SmallButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = const Color(0xff001743),
    this.foregroundColor = Colors.white,
    this.borderColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 3,
        textStyle: const TextStyle(
          fontFamily: "Jost",
          fontWeight: FontWeight.w400,
          fontSize: 18,
        ),
        minimumSize: const Size(135, 70),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(color: borderColor, width: 0.5),
        ),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}