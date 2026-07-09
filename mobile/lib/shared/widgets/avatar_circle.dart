import 'package:flutter/material.dart';

class AvatarCircle extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  final IconData? icon;
  final double size;
  final Color backgroundColor;

  const AvatarCircle({
    super.key,
    this.name,
    this.imageUrl,
    this.icon,
    this.size = 44,
    this.backgroundColor = const Color(0xFF818CF8),
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: backgroundColor.withValues(alpha: 0.12),
        backgroundImage: NetworkImage(imageUrl!),
      );
    }

    if (icon != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: backgroundColor.withValues(alpha: 0.15),
        child: Icon(icon, color: backgroundColor, size: size * 0.5),
      );
    }

    final initial =
        (name != null && name!.trim().isNotEmpty) ? name!.trim()[0].toUpperCase() : '?';

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor.withValues(alpha: 0.15),
      child: Text(
        initial,
        style: TextStyle(
          color: backgroundColor,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}