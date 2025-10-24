import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AppointmentPieChart extends StatefulWidget {
  const AppointmentPieChart({super.key});

  @override
  State<AppointmentPieChart> createState() => _AppointmentPieChartState();
}

class _AppointmentPieChartState extends State<AppointmentPieChart> {
  Map<String, double> _statusCounts = {
    'pending': 0,
    'approved': 0,
    'rejected': 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointmentStatus();
  }

  Future<void> _fetchAppointmentStatus() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('appointments').get();
      final Map<String, double> counts = {
        'pending': 0,
        'approved': 0,
        'rejected': 0,
      };

      for (var doc in snapshot.docs) {
        final status = doc.data()['status'] as String? ?? 'pending';
        counts[status] = (counts[status] ?? 0) + 1;
      }

      setState(() {
        _statusCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error, e.g., show a snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<PieChartSectionData> sections = _statusCounts.entries.map((entry) {
      return PieChartSectionData(
        color: _getColorForStatus(entry.key),
        value: entry.value,
        title: '${entry.value.toInt()}',
        radius: 50.0,
        titleStyle: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Color(0xffffffff),
        ),
      );
    }).toList();

    return Column(
      children: [
        const Text(
          'Appointment Status Distribution',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              borderData: FlBorderData(show: false),
              sectionsSpace: 0,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _statusCounts.keys.map((status) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: _getColorForStatus(status),
                  ),
                  const SizedBox(width: 4),
                  Text(status.toUpperCase()),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getColorForStatus(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
