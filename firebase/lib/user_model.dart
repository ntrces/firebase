
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final int age;

  User({
    required this.id,
    required this.name,
    required this.age,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
    );
  }
}
