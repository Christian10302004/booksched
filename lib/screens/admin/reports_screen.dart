import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Future<Map<String, dynamic>> _getReportData() async {
    final appointmentsSnapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('status', isEqualTo: 'approved')
        .get();

    double totalIncome = 0;
    List<Map<String, dynamic>> transactions = [];

    for (var appointmentDoc in appointmentsSnapshot.docs) {
      final appointmentData = appointmentDoc.data();
      final serviceSnapshot = await FirebaseFirestore.instance
          .collection('services')
          .doc(appointmentData['serviceId'])
          .get();

      if (serviceSnapshot.exists) {
        final serviceData = serviceSnapshot.data()!;
        totalIncome += serviceData['price'];

        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(appointmentData['userId'])
            .get();
        
        transactions.add({
          'userEmail': userSnapshot.exists ? userSnapshot.data()!['email'] : 'N/A',
          'serviceName': serviceData['name'],
          'price': serviceData['price'],
          'date': (appointmentData['dateTime'] as Timestamp).toDate(),
        });
      }
    }

    return {
      'totalIncome': totalIncome,
      'transactions': transactions,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Reports'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getReportData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available.'));
          }

          final reportData = snapshot.data!;
          final totalIncome = reportData['totalIncome'];
          final transactions = (reportData['transactions'] as List).reversed.toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Total Income',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '\$${totalIncome.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 36, color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(thickness: 2),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Transaction History',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: transactions.isEmpty
                    ? const Center(child: Text('No approved appointments found.'))
                    : ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.receipt_long, color: Colors.blueAccent),
                              title: Text(transaction['serviceName']),
                              subtitle: Text(
                                  'Customer: ${transaction['userEmail']} - ${transaction['date'].toLocal().toString().split(' ')[0]}'),
                              trailing: Text(
                                '\$${transaction['price'].toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
