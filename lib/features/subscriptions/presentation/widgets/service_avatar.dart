import 'package:flutter/material.dart';

/// A stand-in "logo": the service's initial on a color derived from its name.
class ServiceAvatar extends StatelessWidget {
  const ServiceAvatar({required this.name, this.size = 44, super.key});

  final String name;
  final double size;

  static const _palette = [
    Color(0xFFE0533D),
    Color(0xFF2E9E5B),
    Color(0xFF3D8BE0),
    Color(0xFF8E5BE0),
    Color(0xFFF2A44E),
    Color(0xFFE05B9E),
    Color(0xFF2E7D6B),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _palette[name.hashCode.abs() % _palette.length];
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}
