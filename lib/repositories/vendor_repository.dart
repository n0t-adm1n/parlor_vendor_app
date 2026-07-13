import 'package:cloud_firestore/cloud_firestore.dart';

class VendorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addService(String branchId, Map<String, dynamic> serviceData) async {
    final newServiceData = {
      ...serviceData,
      'branchId': branchId,
      'isActive': true,
      'image': '',
      'description': '',
      'createdAt': FieldValue.serverTimestamp(),
    };
    
    await _firestore.collection('services').add(newServiceData);
  }

  Future<void> removeService(String serviceId) async {
    await _firestore.collection('services').doc(serviceId).delete();
  }
}
