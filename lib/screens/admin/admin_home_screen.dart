import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/main.dart';
import 'package:myapp/screens/admin/widgets/appointment_pie_chart.dart';
import 'package:myapp/screens/admin/widgets/summary_card.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/services/auth_service.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.auto_mode),
            onPressed: () => themeProvider.setSystemTheme(),
            tooltip: 'Set System Theme',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                context.go('/');
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('appointments').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          int totalAppointments = snapshot.data!.docs.length;
          int approvedAppointments = 0;
          int pendingAppointments = 0;

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] as String? ?? 'pending';
            if (status == 'approved') {
              approvedAppointments++;
            } else {
              pendingAppointments++;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SummaryCard(
                      title: 'Total Appointments',
                      count: totalAppointments.toString(),
                      icon: Icons.calendar_today,
                      color: Colors.blue,
                    ),
                    SummaryCard(
                      title: 'Approved',
                      count: approvedAppointments.toString(),
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                    SummaryCard(
                      title: 'Pending',
                      count: pendingAppointments.toString(),
                      icon: Icons.hourglass_bottom,
                      color: Colors.amber,
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                Text(
                  'Management',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  children: <Widget>[
                    _buildDashboardCard(
                      context,
                      icon: Icons.calendar_today,
                      title: 'Manage Appointments',
                      onTap: () => context.go('/admin/appointments'),
                    ),
                    _buildDashboardCard(
                      context,
                      icon: Icons.miscellaneous_services,
                      title: 'Manage Services',
                      onTap: () => context.go('/admin/services'),
                    ),
                    _buildDashboardCard(
                      context,
                      icon: Icons.bar_chart,
                      title: 'View Reports',
                      onTap: () => context.go('/admin/reports'),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                const AppointmentPieChart(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 50.0, color: Theme.of(context).primaryColor),
            const SizedBox(height: 10.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
