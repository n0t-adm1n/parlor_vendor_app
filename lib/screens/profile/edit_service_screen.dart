import 'package:flutter/material.dart';
import 'package:parlor_vendor_app/repositories/vendor_repository.dart';

class EditServiceScreen extends StatefulWidget {
  final String serviceId;
  final Map<String, dynamic> currentData;

  const EditServiceScreen({
    Key? key,
    required this.serviceId,
    required this.currentData,
  }) : super(key: key);

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final VendorRepository _vendorRepository = VendorRepository();
  
  final _formKey = GlobalKey<FormState>();
  late String name;
  late double price;
  late int duration;
  String? selectedCategory;
  late final TextEditingController descriptionController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    name = widget.currentData['name'] ?? '';
    price = (widget.currentData['price'] ?? 0).toDouble();
    duration = widget.currentData['duration'] ?? 0;
    
    // Ensure selected category is valid
    const validCategories = ['hair', 'nail', 'facial', 'makeup', 'spa'];
    final category = widget.currentData['category'];
    if (validCategories.contains(category)) {
      selectedCategory = category;
    }
    
    descriptionController = TextEditingController(text: widget.currentData['description'] ?? '');
  }

  Future<void> _updateService() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => isLoading = true);
      try {
        await _vendorRepository.updateService(
          widget.serviceId,
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
            SnackBar(content: Text('Error updating service: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Service'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              initialValue: name,
              decoration: const InputDecoration(labelText: 'Service Name'),
              validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
              onSaved: (value) => name = value!.trim(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: price.toString(),
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
              initialValue: duration.toString(),
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
              onPressed: isLoading ? null : _updateService,
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Changes', style: TextStyle(fontSize: 16)),
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
