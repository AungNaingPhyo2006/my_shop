import 'package:flutter/material.dart';

class GridNavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget page;

  const GridNavButton({
    super.key,
    required this.label,
    required this.icon,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.deepPurple, width: 1.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.deepPurple),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            )
          ],
        ),
      ),
    );
  }
}
