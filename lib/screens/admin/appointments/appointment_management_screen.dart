import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AppointmentManagementScreen extends StatefulWidget {
  const AppointmentManagementScreen({super.key});

  @override
  State<AppointmentManagementScreen> createState() => _AppointmentManagementScreenState();
}

class _AppointmentManagementScreenState extends State<AppointmentManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Appointments'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('appointments').orderBy('date', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No appointments found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final appointments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              final data = appointment.data() as Map<String, dynamic>;
              final appointmentId = appointment.id;

              final serviceName = data['serviceName'] as String? ?? 'N/A';
              final timestamp = data['date'] as Timestamp?;
              final date = timestamp != null
                  ? DateFormat.yMMMd().add_jm().format(timestamp.toDate())
                  : 'N/A';
              final status = data['status'] as String? ?? 'pending';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                elevation: 4.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  title: Text(
                    serviceName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  subtitle: Text(
                    'Date: $date\nStatus: $status',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (status == 'pending')
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
                          onPressed: () => _approveAppointment(appointmentId),
                          tooltip: 'Approve',
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                        onPressed: () => _deleteAppointment(appointmentId),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _approveAppointment(String appointmentId) {
    _firestore.collection('appointments').doc(appointmentId).update({'status': 'approved'}).then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment Approved')),
      );
    }).catchError((error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve appointment: $error')),
      );
    });
  }

  void _deleteAppointment(String appointmentId) {
    _firestore.collection('appointments').doc(appointmentId).delete().then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment Deleted')),
      );
    }).catchError((error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete appointment: $error')),
      );
    });
  }
}
