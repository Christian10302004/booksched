
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AppointmentPieChart extends StatelessWidget {
  const AppointmentPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('appointments').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        int pendingCount = 0;
        int approvedCount = 0;

        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] as String? ?? 'pending';
          if (status == 'pending') {
            pendingCount++;
          } else if (status == 'approved') {
            approvedCount++;
          }
        }
        
        if (pendingCount == 0 && approvedCount == 0) {
          return const Center(child: Text('No appointment data for chart.'));
        }

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Appointment Status', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          color: Colors.amber,
                          value: pendingCount.toDouble(),
                          title: '$pendingCount',
                          radius: 50,
                          titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        PieChartSectionData(
                          color: Colors.green,
                          value: approvedCount.toDouble(),
                          title: '$approvedCount',
                          radius: 50,
                          titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(width: 16, height: 16, color: Colors.amber),
                        const SizedBox(width: 8),
                        const Text('Pending'),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Row(
                      children: [
                        Container(width: 16, height: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text('Approved'),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
