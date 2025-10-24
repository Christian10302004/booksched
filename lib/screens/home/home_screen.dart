import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('BookSched Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) {
                context.go('/');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to BookSched!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Book Appointment'),
                onPressed: () => context.go('/book'),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_month),
                label: const Text('View Appointments'),
                onPressed: () => context.go('/appointments'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
