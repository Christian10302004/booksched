import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../models/appointment_model.dart';
import '../../../providers/appointment_provider.dart';
import '../../../services/auth/auth_service.dart';

class UserAppointmentsScreen extends StatelessWidget {
  const UserAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthService>(context, listen: false).user!.uid;
    final appointmentProvider = Provider.of<AppointmentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
      ),
      body: StreamBuilder<List<Appointment>>(
        stream: appointmentProvider.getAppointments(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final appointments = snapshot.data ?? [];

          if (appointments.isEmpty) {
            return const Center(child: Text('You have no appointments.'));
          }

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(appointment.serviceName),
                  subtitle: Text(
                    'Date: ${DateFormat.yMd().add_jm().format(appointment.date)}\nStatus: ${appointment.status.toUpperCase()}',
                  ),
                  isThreeLine: true,
                  trailing: appointment.status == 'pending'
                      ? IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            context.go('/user/appointments/edit', extra: appointment);
                          },
                        )
                      : Text(
                          appointment.status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(appointment.status),
                            fontWeight: FontWeight.bold,
                          ),
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
}
