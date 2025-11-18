import 'package:flutter/material.dart';

class custom_notification extends StatelessWidget {
  final IconData leadingIcon;
  final Color leadingColor;
  final String title;
  final String subtitle;
  final IconData trailingIcon;
  final Color trailingColor;

  const custom_notification({
    super.key,
    required this.leadingIcon,
    required this.leadingColor,
    required this.title,
    required this.subtitle,
    required this.trailingIcon,
    required this.trailingColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(leadingIcon, size: 32, color: leadingColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(trailingIcon, size: 28, color: trailingColor),
          ],
        ),
      ),
    );
  }
}