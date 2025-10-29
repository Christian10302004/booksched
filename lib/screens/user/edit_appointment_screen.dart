import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../models/appointment_model.dart';
import '../../../providers/appointment_provider.dart';

class EditAppointmentScreen extends StatefulWidget {
  final Appointment appointment;

  const EditAppointmentScreen({super.key, required this.appointment});

  @override
  State<EditAppointmentScreen> createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.appointment.date;
    _selectedTime = TimeOfDay.fromDateTime(widget.appointment.date);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Appointment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service: ${widget.appointment.serviceName}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text('Date: ${DateFormat.yMd().format(_selectedDate)}'),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Change Date'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text('Time: ${_selectedTime.format(context)}'),
                ),
                TextButton(
                  onPressed: () => _selectTime(context),
                  child: const Text('Change Time'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  _selectedTime.hour,
                  _selectedTime.minute,
                );
                final updatedAppointment = Appointment(
                  id: widget.appointment.id,
                  userId: widget.appointment.userId,
                  userName: widget.appointment.userName,
                  serviceId: widget.appointment.serviceId,
                  serviceName: widget.appointment.serviceName,
                  date: newDate,
                  status: widget.appointment.status,
                );
                context.read<AppointmentProvider>().updateAppointment(
                  widget.appointment.id,
                  updatedAppointment,
                );
                context.go('/user/appointments');
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
