import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClockCubit extends Cubit<DateTime> {
  Timer? _t;
  ClockCubit() : super(DateTime.now().toUtc().add(const Duration(hours: 7))) {
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      emit(DateTime.now().toUtc().add(const Duration(hours: 7)));
    });
  }
  @override
  Future<void> close() {
    _t?.cancel();
    return super.close();
  }
}
