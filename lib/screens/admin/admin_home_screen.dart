import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/widgets/appointment_pie_chart.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  Future<void> _showLogoutConfirmationDialog(BuildContext context, AuthService authService) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must choose an action
      builder: (BuildContext dialogContext) {
        bool isLoggingOut = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Confirm Logout'),
              content: isLoggingOut
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 24),
                        Text('Logging out...'),
                      ],
                    )
                  : const Text('Are you sure you want to log out?'),
              actions: isLoggingOut
                  ? [] // Hide actions while logging out
                  : <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(dialogContext).pop(); // Close the dialog
                        },
                      ),
                      TextButton(
                        child: const Text('Logout'),
                        onPressed: () async {
                          setState(() {
                            isLoggingOut = true;
                          });
                          try {
                            await authService.signOut();
                            if (dialogContext.mounted) {
                              // Use root navigator to avoid issues with context
                              Navigator.of(dialogContext, rootNavigator: true).pop();
                              GoRouter.of(context).go('/login');
                            }
                          } catch (e) {
                            // Handle error, maybe show a snackbar
                            setState(() {
                              isLoggingOut = false;
                            });
                            // Optionally show an error message
                          }
                        },
                      ),
                    ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmationDialog(context, authService),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    height: 300,
                    child: AppointmentPieChart(),
                  ),
                ),
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                _buildDashboardCard(
                  context,
                  'Manage Services',
                  Icons.build,
                  () => context.go('/admin/services'),
                ),
                _buildDashboardCard(
                  context,
                  'Manage Appointments',
                  Icons.calendar_today,
                  () => context.go('/admin/appointments'),
                ),
                _buildDashboardCard(
                  context,
                  'View Reports',
                  Icons.bar_chart,
                  () => context.go('/admin/reports'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 50.0, color: Theme.of(context).primaryColor),
            const SizedBox(height: 10.0),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
