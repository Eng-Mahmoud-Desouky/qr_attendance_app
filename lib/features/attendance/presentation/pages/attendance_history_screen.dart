import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/attendance_history_cubit.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../../features/auth/presentation/cubit/auth_state.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    print('');
    print('═══════════════════════════════════════════════════');
    print('📱 [HISTORY SCREEN] Loading History');
    print('═══════════════════════════════════════════════════');

    final authState = context.read<AuthCubit>().state;
    print('🔍 Auth State: ${authState.runtimeType}');

    if (authState is AuthAuthenticated) {
      print('✅ User is authenticated');
      print('   ├─ Student ID: ${authState.student.id}');
      print('   ├─ Student Name: ${authState.student.name}');
      print('   └─ Student Email: ${authState.student.email}');
      print('═══════════════════════════════════════════════════');
      print('🚀 Calling loadHistory with student ID: ${authState.student.id}');
      print('');

      context.read<AttendanceHistoryCubit>().loadHistory(authState.student.id);
    } else {
      print('❌ User is NOT authenticated');
      print('   └─ Auth State: ${authState.runtimeType}');
      print('═══════════════════════════════════════════════════');
      print('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: BlocBuilder<AttendanceHistoryCubit, AttendanceHistoryState>(
        builder: (context, state) {
          if (state is AttendanceHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AttendanceHistoryFailure) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is AttendanceHistoryLoaded) {
            final records = state.records;
            if (records.isEmpty) {
              return const Center(child: Text('No attendance records found.'));
            }
            return RefreshIndicator(
              onRefresh: () async => _loadHistory(),
              child: ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  return ListTile(
                    title: Text(record.lectureTitle),
                    subtitle: Text(
                      DateFormat.yMMMd().add_jm().format(record.date),
                    ),
                    trailing: Text(
                      record.status,
                      style: TextStyle(
                        color: record.status.toLowerCase() == 'present'
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const Center(child: Text('Initial State'));
        },
      ),
    );
  }
}
