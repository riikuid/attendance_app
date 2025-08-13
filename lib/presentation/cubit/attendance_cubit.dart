import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/attendance.dart';
import '../../data/repositories/attendance_repository.dart';

class TodayState {
  final bool loading;
  final Attendance? data; // null = belum check-in hari ini
  final String? error;

  const TodayState({this.loading = false, this.data, this.error});

  TodayState copyWith({bool? loading, Attendance? data, String? error}) =>
      TodayState(
        loading: loading ?? this.loading,
        data: data ?? this.data,
        error: error,
      );

  bool get checkedIn => data != null;
  bool get checkedOut => data?.isCheckedOut ?? false;
}

class AttendanceCubit extends Cubit<TodayState> {
  final AttendanceRepository repo;
  StreamSubscription? _sub;

  AttendanceCubit(this.repo) : super(const TodayState());

  void bind(String uid) {
    _sub?.cancel();
    emit(const TodayState(loading: true));
    _sub = repo.today(uid: uid).listen((att) {
      emit(TodayState(data: att));
    }, onError: (e) => emit(TodayState(error: e.toString())));
  }

  Future<void> checkIn(String uid, String email) async {
    try {
      await repo.checkIn(uid: uid, email: email);
    } catch (e) {
      emit(TodayState(data: state.data, error: e.toString()));
    }
  }

  Future<void> checkOut(String uid) async {
    try {
      await repo.checkOut(uid: uid);
    } catch (e) {
      emit(TodayState(data: state.data, error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
