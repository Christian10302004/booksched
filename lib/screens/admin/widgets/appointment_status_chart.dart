import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AppointmentStatusChart extends StatefulWidget {
  const AppointmentStatusChart({super.key});

  @override
  State<AppointmentStatusChart> createState() => _AppointmentStatusChartState();
}

class _AppointmentStatusChartState extends State<AppointmentStatusChart> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('appointments').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No appointment data for chart.'));
        }

        // Process data for the chart
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

        return AspectRatio(
          aspectRatio: 1.7,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (pendingCount + approvedCount) * 1.2, // Give some headroom
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String status;
                        switch (group.x.toInt()) {
                          case 0:
                            status = 'Pending';
                            break;
                          case 1:
                            status = 'Approved';
                            break;
                          default:
                            throw Error();
                        }
                        return BarTooltipItem(
                          '$status\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: (rod.toY - 1).toString(),
                              style: const TextStyle(
                                color: Colors.yellow,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                     show: true,
                     bottomTitles: AxisTitles(
                       sideTitles: SideTitles(
                         showTitles: true,
                         getTitlesWidget: (double value, TitleMeta meta) {
                            const style = TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            );
                            String text;
                            switch (value.toInt()) {
                              case 0:
                                text = 'Pending';
                                break;
                              case 1:
                                text = 'Approved';
                                break;
                              default:
                                text = '';
                                break;
                            }
                            return Text(text, style: style);
                         },
                         reservedSize: 30,
                       ),
                     ),
                     leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                     topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                     rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                            toY: pendingCount.toDouble() + 1,
                            color: Colors.amber,
                            width: 22,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                            toY: approvedCount.toDouble() + 1,
                            color: Colors.green,
                            width: 22
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
