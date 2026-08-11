import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parlor_vendor_app/screens/dashboard/vendor_dashboard_screen.dart';

class VendorRegistrationScreen extends StatefulWidget {
  const VendorRegistrationScreen({super.key});

  @override
  State<VendorRegistrationScreen> createState() => _VendorRegistrationScreenState();
}

class _VendorRegistrationScreenState extends State<VendorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String vendorType = 'parlor';
  String selectedCity = 'Kanpur';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        String uid = userCredential.user!.uid;

        await FirebaseFirestore.instance.collection('branches').doc(uid).set({
          'branchId': uid,
          'name': _nameController.text.trim(),
          'searchName': _nameController.text.trim().toLowerCase(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'vendorType': vendorType,
          'isActive': true,
          'businessId': uid,
          'city': selectedCity,
          'geohash': '',
          'location': const GeoPoint(26.4499, 80.3319),
          'rating': 0.0,
          'reviewCount': 0,
          'timezone': 'Asia/Kolkata',
          'updatedAt': FieldValue.serverTimestamp(),
          'workingHours': {
            'Monday': '09:00 AM - 08:00 PM',
            'Tuesday': '09:00 AM - 08:00 PM',
            'Wednesday': '09:00 AM - 08:00 PM',
            'Thursday': '09:00 AM - 08:00 PM',
            'Friday': '09:00 AM - 08:00 PM',
            'Saturday': '10:00 AM - 09:00 PM',
            'Sunday': '10:00 AM - 09:00 PM',
          },
        });

        // Also create the vendor user profile linking to this branch
        await FirebaseFirestore.instance.collection('vendor_users').doc(uid).set({
          'userId': uid,
          'branchId': uid,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': 'owner', // Default role for the creator
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VendorDashboardScreen(branchId: uid),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Registration failed')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An error occurred: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Registration'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter your name or business name',
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter email address',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter password',
                  ),
                  obscureText: true,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    hintText: 'Enter phone number',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Vendor Type', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Salon Owner'),
                        value: 'parlor',
                        groupValue: vendorType,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              vendorType = value;
                            });
                          }
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Freelancer'),
                        value: 'freelancer',
                        groupValue: vendorType,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              vendorType = value;
                            });
                          }
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: selectedCity,
                  decoration: const InputDecoration(
                    labelText: 'City',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Kanpur', child: Text('Kanpur')),
                    DropdownMenuItem(value: 'Lucknow', child: Text('Lucknow')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCity = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address / Area',
                    hintText: vendorType == 'parlor' 
                        ? 'Salon Physical Address' 
                        : 'Base City / Operating Area',
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  maxLines: 2,
                ),
                const SizedBox(height: 32),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _signUp,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
