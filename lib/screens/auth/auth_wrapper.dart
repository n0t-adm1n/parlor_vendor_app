import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parlor_vendor_app/screens/auth/login_screen.dart';
import 'package:parlor_vendor_app/screens/dashboard/vendor_dashboard_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // Show loading spinner while auth state is initializing
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is not logged in, show LoginScreen
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const LoginScreen();
        }

        // If user is logged in, fetch their branchId from vendor_users collection
        final user = authSnapshot.data!;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('vendor_users').doc(user.uid).get(),
          builder: (context, vendorSnapshot) {
            if (vendorSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Loading branch data...',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (vendorSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text(
                    'Error loading vendor data: ${vendorSnapshot.error}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              );
            }

            if (!vendorSnapshot.hasData || !vendorSnapshot.data!.exists) {
              // If vendor user document doesn't exist, we should probably force sign out
              // so they aren't stuck in a blank state
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Vendor profile not found for this account.',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => FirebaseAuth.instance.signOut(),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Document exists, extract branchId
            final data = vendorSnapshot.data!.data() as Map<String, dynamic>?;
            final branchId = data?['branchId'] as String?;

            if (branchId == null || branchId.isEmpty) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'No branch associated with this vendor profile.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            }

            // Route dynamically to the dashboard passing the branchId
            return VendorDashboardScreen(branchId: branchId);
          },
        );
      },
    );
  }
}
