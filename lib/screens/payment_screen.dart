import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text("Платежи", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0),
      body: GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildGridItem(context, Icons.phone_android, "Мобильная\nсвязь"),
          _buildGridItem(context, Icons.lightbulb_outline, "Коммуналка"),
          _buildGridItem(context, Icons.wifi, "Интернет"),
          _buildGridItem(context, Icons.school, "Образование"),
          _buildGridItem(context, Icons.directions_car, "Транспорт"),
          _buildGridItem(context, Icons.more_horiz, "Прочее"),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 30),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}