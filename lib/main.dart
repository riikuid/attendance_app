import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presence_app/data/repositories/attendance_repository.dart';
import 'package:presence_app/presentation/cubit/attendance_cubit.dart';
import 'package:presence_app/presentation/cubit/auth_cubit.dart';
import 'package:presence_app/presentation/cubit/clock_cubit.dart';
import 'package:presence_app/presentation/pages/home_page.dart';
import 'package:presence_app/presentation/pages/sign_in_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AttendanceRepository>(
      create: (_) => AttendanceRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthCubit()),
          // Ambil repo dari context agar urutan dependensi benar
          BlocProvider(
            create: (ctx) => AttendanceCubit(ctx.read<AttendanceRepository>()),
          ),
          BlocProvider(create: (_) => ClockCubit()),
        ],
        child: MaterialApp(
          title: 'Attendance',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF0A7EA4),
          ),
          home: const SignInPage(),
        ),
      ),
    );
  }
}
