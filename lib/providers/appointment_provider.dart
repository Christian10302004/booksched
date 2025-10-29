import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Appointment>> getAppointments(String userId) {
    return _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromFirestore(doc))
            .toList());
  }

  Stream<List<Appointment>> getAllAppointments() {
    return _firestore
        .collection('appointments')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromFirestore(doc))
            .toList());
  }

  Future<void> addAppointment(Appointment appointment) async {
    try {
      await _firestore.collection('appointments').add(appointment.toMap());
      notifyListeners();
    } catch (error, stackTrace) {
      developer.log(
        'Failed to add appointment',
        name: 'AppointmentProvider',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> updateAppointment(String id, Appointment appointment) async {
    try {
      await _firestore.collection('appointments').doc(id).update(appointment.toMap());
      notifyListeners();
    } catch (error, stackTrace) {
      developer.log(
        'Failed to update appointment',
        name: 'AppointmentProvider',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> updateAppointmentStatus(String id, String status) async {
    try {
      await _firestore.collection('appointments').doc(id).update({'status': status});
      notifyListeners();
    } catch (error, stackTrace) {
      developer.log(
        'Failed to update appointment status',
        name: 'AppointmentProvider',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> deleteAppointment(String id) async {
    try {
      await _firestore.collection('appointments').doc(id).delete();
      notifyListeners();
    } catch (error, stackTrace) {
      developer.log(
        'Failed to delete appointment',
        name: 'AppointmentProvider',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
