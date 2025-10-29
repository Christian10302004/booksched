import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../models/appointment_model.dart';
import '../../../providers/appointment_provider.dart';

class AppointmentManagementScreen extends StatelessWidget {
  const AppointmentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Appointments'),
      ),
      body: StreamBuilder<List<Appointment>>(
        stream: Provider.of<AppointmentProvider>(context, listen: false).getAllAppointments(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final appointments = snapshot.data ?? [];

          if (appointments.isEmpty) {
            return const Center(child: Text('No appointments found.'));
          }

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(appointment.serviceName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Client: ${appointment.userName}'),
                      Text('Date: ${DateFormat.yMd().add_jm().format(appointment.date)}'),
                      Text(
                        'Status: ${appointment.status.toUpperCase()}',
                        style: TextStyle(
                          color: _getStatusColor(appointment.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (appointment.status == 'pending') ...[
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () => _updateStatus(context, appointment.id, 'approved'),
                          tooltip: 'Approve',
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => _updateStatus(context, appointment.id, 'rejected'),
                          tooltip: 'Reject',
                        ),
                      ],
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  void _updateStatus(BuildContext context, String id, String status) {
    Provider.of<AppointmentProvider>(context, listen: false)
        .updateAppointmentStatus(id, status);
  }
}
