import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parlor_vendor_app/models/booking_model.dart';

class BookingRepository {
  Future<void> updateBookingStatus(String bookingId, BookingStatus newStatus) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({'status': newStatus.name});
  }
}
