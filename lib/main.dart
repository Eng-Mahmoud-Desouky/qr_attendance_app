import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/attendance/presentation/cubit/mark_attendance_cubit.dart';
import 'features/attendance/presentation/cubit/attendance_history_cubit.dart';
import 'features/student/presentation/cubit/student_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()),
        BlocProvider(create: (_) => di.sl<MarkAttendanceCubit>()),
        BlocProvider(create: (_) => di.sl<AttendanceHistoryCubit>()),
        BlocProvider(create: (_) => di.sl<StudentCubit>()),
      ],
      child: MaterialApp(
        title: 'Student Attendance',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
