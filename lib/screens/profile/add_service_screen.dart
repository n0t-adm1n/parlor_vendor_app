import 'package:flutter/material.dart';
import 'package:parlor_vendor_app/repositories/vendor_repository.dart';

class AddServiceScreen extends StatefulWidget {
  final String branchId;

  const AddServiceScreen({Key? key, required this.branchId}) : super(key: key);

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final VendorRepository _vendorRepository = VendorRepository();
  
  final _formKey = GlobalKey<FormState>();
  String name = '';
  double price = 0.0;
  int duration = 0;
  String? selectedCategory;
  final TextEditingController descriptionController = TextEditingController();
  bool isLoading = false;

  Future<void> _saveService() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
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
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding service: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Service'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Service Name'),
              validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
              onSaved: (value) => name = value!.trim(),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
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
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: isLoading ? null : _saveService,
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Service', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }
}
