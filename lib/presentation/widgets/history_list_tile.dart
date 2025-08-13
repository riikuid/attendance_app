import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/attendance.dart';

class HistoryListTile extends StatelessWidget {
  final Attendance item;
  const HistoryListTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final d = item.date; // yyyyMMdd
    final dateStr =
        '${d.substring(6, 8)}-${d.substring(4, 6)}-${d.substring(0, 4)}';
    final ci = DateFormat('HH:mm').format(item.checkInAt.toLocal());
    final co =
        item.checkOutAt != null
            ? DateFormat('HH:mm').format(item.checkOutAt!.toLocal())
            : '-';

    return ListTile(
      title: Text(dateStr),
      subtitle: Text('In: $ci  •  Out: $co'),
    );
  }
}
