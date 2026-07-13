import 'package:cloud_firestore/cloud_firestore.dart';

class VendorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addService(String branchId, Map<String, dynamic> serviceData) async {
    final newServiceData = {
      'isActive': true,
      'image': '',
      'description': '',
      ...serviceData,
      'branchId': branchId,
      'createdAt': FieldValue.serverTimestamp(),
    };
    
    await _firestore.collection('services').add(newServiceData);
  }

  Future<void> removeService(String serviceId) async {
    await _firestore.collection('services').doc(serviceId).delete();
  }

  Future<void> updateService(String serviceId, Map<String, dynamic> updatedData) async {
    await _firestore.collection('services').doc(serviceId).update(updatedData);
  }

  Future<void> updateBookingStatus(String branchId, bool isActiveStatus) async {
    await _firestore.collection('branches').doc(branchId).set({'isActive': isActiveStatus}, SetOptions(merge: true));
  }
}
