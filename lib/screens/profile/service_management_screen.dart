import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parlor_vendor_app/repositories/vendor_repository.dart';
import 'package:parlor_vendor_app/screens/profile/add_service_screen.dart';

class ServiceManagementScreen extends StatefulWidget {
  final String branchId;

  const ServiceManagementScreen({Key? key, required this.branchId}) : super(key: key);

  @override
  State<ServiceManagementScreen> createState() => _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
  final VendorRepository _vendorRepository = VendorRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Management'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('services')
            .where('branchId', isEqualTo: widget.branchId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No services added yet.'));
          }

          final services = snapshot.data!.docs;

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final doc = services[index];
              final service = doc.data() as Map<String, dynamic>;
              final serviceId = doc.id;

              final name = service['name'] ?? 'Unknown';
              final price = service['price'] ?? 0.0;
              final duration = service['duration'] ?? 0;
              final category = service['category'] ?? 'Uncategorized';

              return ListTile(
                title: Text(name),
                subtitle: Text('$category • ₹${price.toStringAsFixed(2)} • $duration mins'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: Text('Are you sure you want to delete "$name"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      try {
                        await _vendorRepository.removeService(serviceId);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error removing service: $e')),
                          );
                        }
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddServiceScreen(branchId: widget.branchId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
