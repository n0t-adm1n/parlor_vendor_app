// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  confirmed,
  completed,
  cancelled,
  no_show,
}

enum PaymentStatus {
  pending,
  paid,
  refunded,
}

extension BookingStatusParser on String {
  BookingStatus toBookingStatus() {
    switch (this) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'no_show':
        return BookingStatus.no_show;
      case 'pending':
      default:
        return BookingStatus.pending;
    }
  }
}

extension PaymentStatusParser on String {
  PaymentStatus toPaymentStatus() {
    switch (this) {
      case 'paid':
        return PaymentStatus.paid;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'pending':
      default:
        return PaymentStatus.pending;
    }
  }
}

class Booking {
  final String id;
  final String customerUid;
  final String branchId;
  final String bookingNumber;
  final String bookingDateLocal;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final Map<String, dynamic> customerSnapshot;
  final List<Map<String, dynamic>> servicesSnapshot;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.customerUid,
    required this.branchId,
    required this.bookingNumber,
    required this.bookingDateLocal,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    required this.customerSnapshot,
    required this.servicesSnapshot,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    // Safely parse double
    final rawTotalPrice = data['totalPrice'];
    final totalPriceValue = rawTotalPrice is num ? rawTotalPrice.toDouble() : 0.0;

    // Safely parse DateTimes from Firestore Timestamps
    final rawStartTime = data['startTime'];
    final rawEndTime = data['endTime'];
    final rawCreatedAt = data['createdAt'];
    final rawUpdatedAt = data['updatedAt'];

    final startTimeValue = rawStartTime is Timestamp ? rawStartTime.toDate() : DateTime.now();
    final endTimeValue = rawEndTime is Timestamp ? rawEndTime.toDate() : DateTime.now();
    final createdAtValue = rawCreatedAt is Timestamp ? rawCreatedAt.toDate() : DateTime.now();
    final updatedAtValue = rawUpdatedAt is Timestamp ? rawUpdatedAt.toDate() : DateTime.now();

    // Safely parse maps and lists
    final customerSnapshotMap = data['customerSnapshot'] is Map
        ? Map<String, dynamic>.from(data['customerSnapshot'] as Map)
        : <String, dynamic>{};

    final servicesSnapshotList = data['servicesSnapshot'] is List
        ? (data['servicesSnapshot'] as List)
            .map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{})
            .toList()
        : <Map<String, dynamic>>[];

    return Booking(
      id: doc.id,
      customerUid: data['customerUid'] as String? ?? '',
      branchId: data['branchId'] as String? ?? '',
      bookingNumber: data['bookingNumber'] as String? ?? '',
      bookingDateLocal: data['bookingDateLocal'] as String? ?? '',
      startTime: startTimeValue,
      endTime: endTimeValue,
      totalPrice: totalPriceValue,
      status: (data['status'] as String? ?? '').toBookingStatus(),
      paymentStatus: (data['paymentStatus'] as String? ?? '').toPaymentStatus(),
      customerSnapshot: customerSnapshotMap,
      servicesSnapshot: servicesSnapshotList,
      createdAt: createdAtValue,
      updatedAt: updatedAtValue,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerUid': customerUid,
      'branchId': branchId,
      'bookingNumber': bookingNumber,
      'bookingDateLocal': bookingDateLocal,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'totalPrice': totalPrice,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'customerSnapshot': customerSnapshot,
      'servicesSnapshot': servicesSnapshot,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
