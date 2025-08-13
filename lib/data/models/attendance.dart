import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  final String uid;
  final String? email;
  final String date;
  final DateTime checkInAt;
  final DateTime? checkOutAt;

  const Attendance({
    required this.uid,
    required this.date,
    required this.checkInAt,
    this.email,
    this.checkOutAt,
  });

  bool get isCheckedOut => checkOutAt != null;

  Attendance copyWith({
    String? uid,
    String? email,
    String? date,
    DateTime? checkInAt,
    DateTime? checkOutAt,
  }) {
    return Attendance(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      date: date ?? this.date,
      checkInAt: checkInAt ?? this.checkInAt,
      checkOutAt: checkOutAt ?? this.checkOutAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'date': date,
    'checkInAt': Timestamp.fromDate(checkInAt),
    if (checkOutAt != null) 'checkOutAt': Timestamp.fromDate(checkOutAt!),
  };

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      uid: map['uid'] as String,
      email: map['email'] as String?,
      date: map['date'] as String,
      checkInAt: (map['checkInAt'] as Timestamp).toDate(),
      checkOutAt: (map['checkOutAt'] as Timestamp?)?.toDate(),
    );
  }

  factory Attendance.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Attendance.fromMap(data);
  }
}
