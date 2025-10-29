import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../models/appointment_model.dart';

class AppointmentManagementScreen extends StatelessWidget {
  const AppointmentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Appointments'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('appointments').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final appointments = snapshot.data!.docs
              .map((doc) => Appointment.fromFirestore(doc))
              .toList();

          if (appointments.isEmpty) {
            return const Center(
              child: Text('No appointments found.'),
            );
          }

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(appointment.userName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Service: ${appointment.serviceName}'),
                      Text(
                          'Date: ${DateFormat.yMd().format(appointment.date)}'),
                      Text(
                          'Time: ${DateFormat.jm().format(appointment.date)}'),
                      Text(
                        'Status: ${appointment.status}',
                        style: TextStyle(
                          color: appointment.status == 'approved'
                              ? Colors.green
                              : (appointment.status == 'pending'
                                  ? Colors.orange
                                  : Colors.red),
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
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _updateAppointmentStatus(
                              appointment.id, 'approved'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _updateAppointmentStatus(
                              appointment.id, 'denied'),
                        ),
                      ],
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteAppointment(appointment.id),
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

  void _updateAppointmentStatus(String appointmentId, String status) {
    FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .update({'status': status});
  }

  void _deleteAppointment(String appointmentId) {
    FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .delete();
  }
}
