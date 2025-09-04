import 'package:flutter/material.dart';

class FEmissionsCategoryItemTile extends StatelessWidget {
  const FEmissionsCategoryItemTile({
    super.key,
    required this.icon,
    required this.title,
    required this.emissionValue,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String emissionValue;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      leading: Icon(icon, color: Colors.white, size: 30),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18),),
      trailing: emissionValue.isNotEmpty ? Text(emissionValue, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)) : null,
      onTap: onTap,
    );
  }
}