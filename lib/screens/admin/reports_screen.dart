import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
        final price = (serviceData['price'] ?? 0).toDouble();
        totalIncome += price;

        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(appointmentData['userId'])
            .get();

        // Safely handle the dateTime field
        DateTime? appointmentDate;
        if (appointmentData.containsKey('dateTime') && appointmentData['dateTime'] != null) {
          appointmentDate = (appointmentData['dateTime'] as Timestamp).toDate();
        }

        transactions.add({
          'userEmail': userSnapshot.exists ? userSnapshot.data()!['email'] : 'N/A',
          'serviceName': serviceData['name'],
          'price': price,
          'date': appointmentDate, // Can be null now
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
    // Define formatters
    final currencyFormatter = NumberFormat.currency(locale: 'en_PH', symbol: '₱');
    final dateFormatter = DateFormat.yMMMd();

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
            // Provide a more user-friendly error message
            return Center(child: Text('An error occurred while generating the report.\nError: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available.'));
          }

          final reportData = snapshot.data!;
          final totalIncome = reportData['totalIncome'] as double;
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
                          currencyFormatter.format(totalIncome),
                          style: TextStyle(fontSize: 36, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
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
                          final transactionDate = transaction['date'] as DateTime?;
                          final formattedDate = transactionDate != null ? dateFormatter.format(transactionDate.toLocal()) : 'Date not set';

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: Icon(Icons.receipt_long, color: Theme.of(context).colorScheme.secondary),
                              title: Text(transaction['serviceName']),
                              subtitle: Text(
                                  'Customer: ${transaction['userEmail']} - $formattedDate'),
                              trailing: Text(
                                currencyFormatter.format(transaction['price']),
                                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
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
