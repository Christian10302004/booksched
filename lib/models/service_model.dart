import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Service extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final int kid;

  const Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.kid,
  });

  factory Service.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Service(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      kid: (data['kid'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'description': description, 'price': price, 'kid': kid};
  }

  @override
  List<Object?> get props => [id, name, description, price,kid];
}
