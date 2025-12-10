import 'package:flutter/material.dart';
import 'features/attendance/presentation/pages/qr_scanner_screen.dart';
import 'features/attendance/presentation/pages/attendance_history_screen.dart';
import 'features/student/presentation/pages/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HomeButton(
              title: 'Mark Attendance (QR)',
              icon: Icons.qr_code_scanner,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const QrScannerScreen())),
            ),
            const SizedBox(height: 16),
            _HomeButton(
              title: 'Attendance History',
              icon: Icons.history,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AttendanceHistoryScreen())),
            ),
            const SizedBox(height: 16),
            _HomeButton(
              title: 'My Profile',
              icon: Icons.person,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _HomeButton(
      {required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }
}
