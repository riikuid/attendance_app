import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/attendance.dart';

class AttendanceRepository {
  final _db = FirebaseFirestore.instance;

  String _dateWIBFromUtcNow() {
    final wib = DateTime.now().toUtc().add(const Duration(hours: 7));
    return DateFormat('yyyyMMdd').format(wib);
  }

  DocumentReference<Map<String, dynamic>> _doc(String uid, String date) =>
      _db.collection('attendance').doc('${uid}_$date');

  Future<void> checkIn({required String uid, required String email}) async {
    final date = _dateWIBFromUtcNow();
    await _db.runTransaction((tx) async {
      final ref = _doc(uid, date);
      final snap = await tx.get(ref);
      if (snap.exists) {
        final data = Attendance.fromDoc(snap);
        if (!data.isCheckedOut)
          throw Exception('Sudah check-in. Silakan check-out dulu.');
        throw Exception('Hari ini sudah complete.');
      }
      tx.set(ref, {
        'uid': uid,
        'email': email,
        'date': date,
        'checkInAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> checkOut({required String uid}) async {
    final date = _dateWIBFromUtcNow();
    await _db.runTransaction((tx) async {
      final ref = _doc(uid, date);
      final snap = await tx.get(ref);
      if (!snap.exists) throw Exception('Belum check-in hari ini.');
      final data = Attendance.fromDoc(snap);
      if (data.isCheckedOut) throw Exception('Sudah check-out hari ini.');
      tx.update(ref, {'checkOutAt': FieldValue.serverTimestamp()});
    });
  }

  // Hari ini (nullable Attendance)
  Stream<Attendance?> today({required String uid}) {
    final date = _dateWIBFromUtcNow();
    return _doc(
      uid,
      date,
    ).snapshots().map((s) => s.exists ? Attendance.fromDoc(s) : null);
  }

  // Riwayat (list Attendance)
  Stream<List<Attendance>> history({required String uid, int limit = 30}) {
    return _db
        .collection('attendance')
        .where('uid', isEqualTo: uid)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((q) => q.docs.map(Attendance.fromDoc).toList());
  }
}
