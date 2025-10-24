import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewAppointmentsScreen extends StatefulWidget {
  const ViewAppointmentsScreen({super.key});

  @override
  State<ViewAppointmentsScreen> createState() => _ViewAppointmentsScreenState();
}

class _ViewAppointmentsScreenState extends State<ViewAppointmentsScreen> {
  Future<void> _cancelAppointment(String id) async {
    await FirebaseFirestore.instance.collection('appointments').doc(id).delete();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Appointment canceled.")),
    );
  }

  Future<void> _editAppointment(String id, String oldService) async {
    final TextEditingController controller =
        TextEditingController(text: oldService);

    final newService = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Edit Appointment"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: "Service Name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, controller.text.trim());
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (newService != null && mounted) {
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(id)
            .update({'service': newService});
        
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Appointment updated!")),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final appointments = FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: user!.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text("My Appointments")),
      body: StreamBuilder<QuerySnapshot>(
        stream: appointments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No appointments found."));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(data['service']),
                  subtitle: Text("${data['date']} at ${data['time']}"),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editAppointment(doc.id, data['service']);
                      } else if (value == 'cancel') {
                        _cancelAppointment(doc.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'cancel',
                        child: Text('Cancel'),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
