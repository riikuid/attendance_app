import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/models/attendance.dart';
import '../../data/repositories/attendance_repository.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/attendance_cubit.dart';
import '../cubit/clock_cubit.dart';
import '../widgets/history_list_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, auth) {
        final user = auth.user;
        if (user == null) {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.read<AuthCubit>().signInWithGoogle(),
                child: const Text('Continue with Google'),
              ),
            ),
          );
        }

        context.read<AttendanceCubit>().bind(user.uid);

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.displayName ?? 'User'),
                Text(user.email ?? '', style: const TextStyle(fontSize: 12)),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () => context.read<AuthCubit>().signOut(),
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Live clock WIB
                BlocBuilder<ClockCubit, DateTime>(
                  builder:
                      (_, wib) => Text(
                        DateFormat('EEE, dd MMM yyyy • HH:mm:ss').format(wib),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                ),
                const SizedBox(height: 16),

                // Status & Tombol
                BlocBuilder<AttendanceCubit, TodayState>(
                  builder: (_, s) {
                    final statusText =
                        !s.checkedIn
                            ? 'Belum check-in'
                            : s.checkedOut
                            ? 'Selesai hari ini'
                            : 'Sudah check-in: ${DateFormat.Hm().format(s.data!.checkInAt.toLocal())}';

                    final canCheckIn = !s.checkedIn;
                    final canCheckOut = s.checkedIn && !s.checkedOut;

                    return Column(
                      children: [
                        Text(statusText),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilledButton(
                              onPressed:
                                  canCheckIn
                                      ? () => context
                                          .read<AttendanceCubit>()
                                          .checkIn(user.uid, user.email ?? '')
                                      : null,
                              child: const Text('Check-in'),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed:
                                  canCheckOut
                                      ? () => context
                                          .read<AttendanceCubit>()
                                          .checkOut(user.uid)
                                      : null,
                              child: const Text('Check-out'),
                            ),
                          ],
                        ),
                        if (s.error != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            s.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ],
                    );
                  },
                ),

                const Divider(height: 32),

                // Riwayat
                Expanded(
                  child: StreamBuilder<List<Attendance>>(
                    stream: context.read<AttendanceRepository>().history(
                      uid: user.uid,
                      limit: 30,
                    ),
                    builder: (_, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final items = snap.data ?? [];
                      if (items.isEmpty)
                        return const Center(child: Text('Belum ada riwayat'));
                      return ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (_, i) => HistoryListTile(item: items[i]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
