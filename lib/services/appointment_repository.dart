import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'appointments';

  Stream<List<Appointment>> getAppointments() {
    return _firestore.collection(_collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Appointment.fromFirestore(doc)).toList();
    });
  }

  Future<void> addAppointment(Appointment appointment) {
    return _firestore.collection(_collectionPath).add(appointment.toMap());
  }

  Future<void> updateAppointmentStatus(String id, String status) {
    return _firestore.collection(_collectionPath).doc(id).update({'status': status});
  }

  Future<void> updateAppointment(String id, DateTime date) {
    return _firestore.collection(_collectionPath).doc(id).update({'date': date});
  }
}
