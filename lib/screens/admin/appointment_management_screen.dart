import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

          final appointments = snapshot.data!.docs;

          if (appointments.isEmpty) {
            return const Center(
              child: Text('No appointments found.'),
            );
          }

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              final appointmentData = appointment.data() as Map<String, dynamic>;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(appointmentData['userId'])
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(title: Text('Loading...'));
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  final appointmentDate = (appointmentData['dateTime'] as Timestamp).toDate();

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('services')
                        .doc(appointmentData['serviceId'])
                        .get(),
                    builder: (context, serviceSnapshot) {
                      if (!serviceSnapshot.hasData) {
                        return const ListTile(title: Text('Loading...'));
                      }

                      final serviceData = serviceSnapshot.data!.data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(userData['email'] ?? 'No email'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Service: ${serviceData['name'] ?? 'N/A'}'),
                              Text('Date: ${appointmentDate.toLocal()}'.split(' ')[0]),
                              Text('Time: ${TimeOfDay.fromDateTime(appointmentDate).format(context)}'),
                              Text(
                                'Status: ${appointmentData['status']}',
                                style: TextStyle(
                                  color: appointmentData['status'] == 'approved'
                                      ? Colors.green
                                      : (appointmentData['status'] == 'pending'
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
                              if (appointmentData['status'] == 'pending') ...[
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('appointments')
                                        .doc(appointment.id)
                                        .update({'status': 'approved'});
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('appointments')
                                        .doc(appointment.id)
                                        .update({'status': 'denied'});
                                  },
                                ),
                              ],
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection('appointments')
                                      .doc(appointment.id)
                                      .delete();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
