import 'package:cloud_firestore/cloud_firestore.dart';

class VendorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addService(String branchId, Map<String, dynamic> newService) async {
    final docRef = _firestore.collection('branch_details').doc(branchId);
    
    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      List<dynamic> services = List.from(data['services'] ?? []);
      
      services.add(newService);
      
      await docRef.update({'services': services});
    } else {
      await docRef.set({
        'services': [newService]
      });
    }
  }

  Future<void> removeService(String branchId, Map<String, dynamic> serviceToRemove) async {
    final docRef = _firestore.collection('branch_details').doc(branchId);
    
    await docRef.update({
      'services': FieldValue.arrayRemove([serviceToRemove])
    });
  }

  Future<void> updateService(String branchId, List<dynamic> updatedServicesList) async {
    final docRef = _firestore.collection('branch_details').doc(branchId);
    
    await docRef.update({
      'services': updatedServicesList
    });
  }
}
