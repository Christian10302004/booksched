import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
// Trigger hot restart
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
        String status = doc.data()['status'] as String? ?? 'pending';
        if (status == 'denied') {
          status = 'rejected'; // Combine 'denied' into 'rejected'
        }
        if (counts.containsKey(status)) {
          counts[status] = (counts[status] ?? 0) + 1;
        }
      }

      setState(() {
        _statusCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Optionally, show an error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching appointment data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<PieChartSectionData> sections = _statusCounts.entries
        .where((entry) => entry.value > 0) // Only show sections with data
        .map((entry) {
      return PieChartSectionData(
        color: _getColorForStatus(entry.key),
        value: entry.value,
        title: '${entry.value.toInt()}',
        radius: 60.0,
        titleStyle: const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    if (sections.isEmpty) {
      return const Center(child: Text('No appointment data available.'));
    }

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.withAlpha(128))),
              sectionsSpace: 2,
              centerSpaceRadius: 30,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12.0,
          runSpacing: 8.0,
          children: _statusCounts.keys.map((status) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  color: _getColorForStatus(status),
                ),
                const SizedBox(width: 6),
                Text(status.toUpperCase(), style: const TextStyle(fontSize: 12)),
              ],
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
