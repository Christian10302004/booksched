import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/screens/user/book_appointment_screen.dart';
import 'package:myapp/screens/user/view_appointments_screen.dart';
import 'package:myapp/services/auth_service.dart';

class UserHomeScreen extends StatelessWidget {
  final AuthService _auth = AuthService();

  UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BookSched"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              if (!context.mounted) return;
              context.go('/');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookAppointmentScreen()),
              ),
              child: const Text("Book Appointment"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ViewAppointmentsScreen()),
              ),
              child: const Text("View Appointments"),
            ),
          ],
        ),
      ),
    );
  }
}
