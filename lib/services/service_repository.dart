import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';

class ServiceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'services';

  // Get a stream of services
  Stream<List<Service>> getServices() {
    return _firestore.collection(_collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Service.fromFirestore(doc)).toList();
    });
  }

  // Add a new service
  Future<void> addService(Service service) {
    return _firestore.collection(_collectionPath).add(service.toMap());
  }

  // Update an existing service
  Future<void> updateService(Service service) {
    return _firestore.collection(_collectionPath).doc(service.id).update(service.toMap());
  }

  // Delete a service
  Future<void> deleteService(String serviceId) {
    return _firestore.collection(_collectionPath).doc(serviceId).delete();
  }
}
