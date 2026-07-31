import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';

class AnalyticsDashboardScreen extends StatelessWidget {
  const AnalyticsDashboardScreen({Key? key}) : super(key: key);

  Widget _buildListStat(String title, String value, IconData icon, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildMockBarChart(String title, List<double> values, Color color) {
    return AnimatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: values.map((val) {
                  return Container(
                    width: 30,
                    height: 150 * val,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Mon', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                Text('Tue', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                Text('Wed', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                Text('Thu', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                Text('Fri', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Most Ordered Items', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            AnimatedCard(
              child: Column(
                children: [
                  _buildListStat('Chicken Biryani', '320 Orders', Icons.restaurant, AppColors.primaryBlue),
                  const Divider(),
                  _buildListStat('Burger', '285 Orders', Icons.fastfood, AppColors.warningOrange),
                  const Divider(),
                  _buildListStat('Coffee', '260 Orders', Icons.local_cafe, AppColors.successGreen),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Peak Time Slots', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            AnimatedCard(
              child: Column(
                children: [
                  _buildListStat('1:00 PM', '420 Orders', Icons.access_time, AppColors.errorRed),
                  const Divider(),
                  _buildListStat('12:30 PM', '380 Orders', Icons.access_time, AppColors.warningOrange),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildMockBarChart('Revenue Chart', [0.4, 0.7, 0.5, 0.9, 0.6], AppColors.successGreen),
            const SizedBox(height: 16),
            _buildMockBarChart('Daily Orders Chart', [0.6, 0.5, 0.8, 0.7, 0.9], AppColors.primaryBlue),
            const SizedBox(height: 16),
            _buildMockBarChart('Queue Performance Chart', [0.3, 0.4, 0.2, 0.5, 0.3], AppColors.warningOrange),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
