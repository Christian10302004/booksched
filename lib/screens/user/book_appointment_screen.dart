import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../models/service_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/service_provider.dart';
import '../../models/appointment_model.dart';
import '../../services/auth/auth_service.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  Service? _selectedService;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    final serviceProvider = Provider.of<ServiceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book an Appointment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/user'),
          tooltip: 'Back',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Service>>(
          stream: serviceProvider.services,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final services = snapshot.data ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (services.isNotEmpty)
                  DropdownButtonFormField<Service>(
                    initialValue: _selectedService,
                    onChanged: (Service? newValue) {
                      setState(() {
                        _selectedService = newValue;
                      });
                    },
                    items: services.map((Service service) {
                      return DropdownMenuItem<Service>(
                        value: service,
                        child: Text(service.name),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Select a Service',
                      border: OutlineInputBorder(),
                    ),
                  ),
                const SizedBox(height: 20),
                ListTile(
                  title: Text(_selectedDate == null
                      ? 'No date selected'
                      : 'Selected Date: ${_selectedDate!.toLocal()}'.split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 20),
                ListTile(
                  title: Text(_selectedTime == null
                      ? 'No time selected'
                      : 'Selected Time: ${_selectedTime!.format(context)}'),
                  trailing: const Icon(Icons.access_time),
                  onTap: _pickTime,
                ),
                const SizedBox(height: 20),
                ListTile(
                  title: const Text('Input Age:'),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _bookAppointment,
                    child: const Text('Confirm Appointment'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _bookAppointment() async {
    if (!mounted) return;
    if (_selectedService == null || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a service, date, and time.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = Provider.of<AuthService>(context, listen: false).user!;
    
    final appointmentDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final appointment = Appointment(
      id: '', // Firestore will generate this
      userId: user.uid,
      userName: user.displayName ?? user.email!,
      serviceId: _selectedService!.id,
      serviceName: _selectedService!.name,
      date: appointmentDateTime,
      status: 'pending',
    );

    try {
      await Provider.of<AppointmentProvider>(context, listen: false)
          .addAppointment(appointment);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment booked successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/user/appointments');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to book appointment: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
