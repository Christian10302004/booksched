import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageServicesScreen extends StatefulWidget {
  const ManageServicesScreen({super.key});

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addService([DocumentSnapshot? service]) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    if (service != null) {
      nameController.text = service['name'];
      descriptionController.text = service['description'];
      priceController.text = service['price'].toString();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(service == null ? 'Add Service' : 'Edit Service'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Service Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final String name = nameController.text;
                final String description = descriptionController.text;
                final double? price = double.tryParse(priceController.text);

                if (name.isNotEmpty && description.isNotEmpty && price != null) {
                  if (service == null) {
                    await _firestore.collection('services').add({
                      'name': name,
                      'description': description,
                      'price': price,
                    });
                  } else {
                    await _firestore.collection('services').doc(service.id).update({
                      'name': name,
                      'description': description,
                      'price': price,
                    });
                  }
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                } else {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields correctly.')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteService(String serviceId) {
    _firestore.collection('services').doc(serviceId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Services'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('services').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final services = snapshot.data!.docs;

          if (services.isEmpty) {
            return const Center(
              child: Text('No services found. Add one to get started!'),
            );
          }

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return ListTile(
                title: Text(service['name']),
                subtitle: Text(
                  '${service['description']} - \$${service['price']}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _addService(service),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteService(service.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addService(),
        tooltip: 'Add Service',
        child: const Icon(Icons.add),
      ),
    );
  }
}
