import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class ViewAppointmentsScreen extends StatefulWidget {
  const ViewAppointmentsScreen({super.key});

  @override
  State<ViewAppointmentsScreen> createState() => _ViewAppointmentsScreenState();
}

class _ViewAppointmentsScreenState extends State<ViewAppointmentsScreen> {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Appointments'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
            tooltip: 'Back',
          ),
        ),
        body: const Center(
          child: Text('Please log in to see your appointments.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/user'),
          tooltip: 'Back',
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (streamContext, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final appointments = snapshot.data!.docs;

          if (appointments.isEmpty) {
            return const Center(child: Text('You have no appointments.'));
          }

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (listContext, index) {
              final appointment = appointments[index];
              final appointmentData =
                  appointment.data() as Map<String, dynamic>;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('services')
                    .doc(appointmentData['serviceId'])
                    .get(),
                builder: (futureContext, serviceSnapshot) {
                  if (!serviceSnapshot.hasData) {
                    return const ListTile(title: Text('Loading...'));
                  }

                  final serviceData =
                      serviceSnapshot.data!.data() as Map<String, dynamic>;
                  
                  final dynamic dateValue = appointmentData['date'];
                  final appointmentDate = dateValue is Timestamp ? dateValue.toDate() : DateTime.now();

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: ListTile(
                      title: Text(serviceData['name'] ?? 'N/A'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date: ${appointmentDate.toLocal()}'.split(' ')[0],
                          ),
                          Text(
                            'Time: ${TimeOfDay.fromDateTime(appointmentDate).format(listContext)}',
                          ),
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
                      trailing: _EditAppointmentButton(
                        appointment: appointment,
                      ),
                    ),
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

class _EditAppointmentButton extends StatefulWidget {
  final DocumentSnapshot appointment;

  const _EditAppointmentButton({required this.appointment});

  @override
  _EditAppointmentButtonState createState() => _EditAppointmentButtonState();
}

class _EditAppointmentButtonState extends State<_EditAppointmentButton> {
  Future<void> _handleEditAppointment() async {
    final appointmentData = widget.appointment.data() as Map<String, dynamic>;
    final dynamic dateValue = appointmentData['date'];
    final currentDateTime = dateValue is Timestamp ? dateValue.toDate() : DateTime.now();

    if (!mounted) return;
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: currentDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (newDate == null) return;

    if (!mounted) return;
    TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentDateTime),
    );

    if (newTime == null) return;

    final newDateTime = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      newTime.hour,
      newTime.minute,
    );

    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(widget.appointment.id)
        .update({
          'date': Timestamp.fromDate(newDateTime),
          'status': 'pending',
        });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appointment updated and is pending approval.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointmentData = widget.appointment.data() as Map<String, dynamic>;
    final status = appointmentData['status'] as String? ?? 'pending';

    if (status != 'pending') {
      return Text(
        status.toUpperCase(),
        style: TextStyle(
          color: status == 'approved' ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: _handleEditAppointment,
    );
  }
}
