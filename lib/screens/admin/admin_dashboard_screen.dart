import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../services/auth/auth_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        bool isLoggingOut = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Logout'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    isLoggingOut
                        ? const Center(child: CircularProgressIndicator())
                        : const Text('Are you sure you want to log out?'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: isLoggingOut
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: isLoggingOut
                      ? null
                      : () async {
                          setState(() {
                            isLoggingOut = true;
                          });
                          try {
                            await Provider.of<AuthService>(context, listen: false)
                                .signOut();
                            // The router's redirect will handle navigation.
                            if (context.mounted) {
                              Navigator.of(context).pop(); // Close the dialog
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Logout failed: $e')),
                              );
                            }
                            setState(() {
                              isLoggingOut = false;
                            });
                          }
                        },
                  child: const Text('Logout'),
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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmationDialog(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/admin/services'),
              child: const Text('Manage Services'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/admin/appointments'),
              child: const Text('Manage Appointments'),
            ),
          ],
        ),
      ),
    );
  }
}
