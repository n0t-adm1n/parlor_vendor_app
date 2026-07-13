import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parlor_vendor_app/repositories/vendor_repository.dart';

class ServiceManagementScreen extends StatefulWidget {
  final String branchId;

  const ServiceManagementScreen({Key? key, required this.branchId}) : super(key: key);

  @override
  State<ServiceManagementScreen> createState() => _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
  final VendorRepository _vendorRepository = VendorRepository();

  void _showAddServiceDialog() {
    final formKey = GlobalKey<FormState>();
    String name = '';
    double price = 0.0;
    int duration = 0;
    String? selectedCategory;
    final TextEditingController descriptionController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Service'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Service Name'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                        onSaved: (value) => name = value!.trim(),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Required';
                          if (double.tryParse(value.trim()) == null) return 'Invalid number';
                          return null;
                        },
                        onSaved: (value) => price = double.parse(value!.trim()),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Duration (mins)'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Required';
                          if (int.tryParse(value.trim()) == null) return 'Invalid number';
                          return null;
                        },
                        onSaved: (value) => duration = int.parse(value!.trim()),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Category'),
                        value: selectedCategory,
                        items: const [
                          DropdownMenuItem(value: 'hair', child: Text('hair')),
                          DropdownMenuItem(value: 'nail', child: Text('nail')),
                          DropdownMenuItem(value: 'facial', child: Text('facial')),
                          DropdownMenuItem(value: 'makeup', child: Text('makeup')),
                          DropdownMenuItem(value: 'spa', child: Text('spa')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                        validator: (value) => value == null ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: descriptionController,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        maxLines: null,
                        decoration: const InputDecoration(
                          labelText: 'Short Description',
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            setState(() => isLoading = true);
                            try {
                              await _vendorRepository.addService(
                                widget.branchId,
                                {
                                  'name': name,
                                  'price': price,
                                  'duration': duration,
                                  'category': selectedCategory,
                                  'description': descriptionController.text,
                                },
                              );
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              setState(() => isLoading = false);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error adding service: $e')),
                                );
                              }
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
        onPressed: _showAddServiceDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
