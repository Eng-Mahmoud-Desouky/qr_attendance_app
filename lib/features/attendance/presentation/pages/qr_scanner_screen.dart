import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../cubit/mark_attendance_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import 'dart:convert';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool isProcessing = false;
  bool isDialogShown = false; // منع تكرار الـ Dialogs

  @override
  void dispose() {
    // Reset the cubit state when leaving the screen
    context.read<MarkAttendanceCubit>().reset();
    super.dispose();
  }

  void _showLoadingDialog() {
    if (isDialogShown) return; // منع تكرار الـ Dialog
    isDialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false, // منع إغلاق الـ Dialog بالـ Back Button
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _closeDialog() {
    if (!isDialogShown) return;
    isDialogShown = false;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _showSuccessDialog(String message) {
    if (isDialogShown) _closeDialog(); // إغلاق أي dialog سابق
    isDialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('✅ نجح'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                _closeDialog();
                // Reset state before going back
                context.read<MarkAttendanceCubit>().reset();
                Navigator.of(context).pop(); // Go back to Home
              },
              child: const Text('حسناً'),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    if (isDialogShown) _closeDialog(); // إغلاق أي dialog سابق
    isDialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('❌ خطأ'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                _closeDialog();
                // Reset state and allow scanning again
                context.read<MarkAttendanceCubit>().reset();
                setState(() => isProcessing = false);
              },
              child: const Text('حسناً'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مسح كود QR'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Reset state before going back
            context.read<MarkAttendanceCubit>().reset();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: BlocListener<MarkAttendanceCubit, MarkAttendanceState>(
        listener: (context, state) {
          print('[QR SCANNER] State changed: ${state.runtimeType}');

          if (state is MarkAttendanceLoading) {
            setState(() => isProcessing = true);
            _showLoadingDialog();
          } else if (state is MarkAttendanceSuccess) {
            setState(
              () => isProcessing = true,
            ); // Keep processing true until user dismisses
            _showSuccessDialog(state.message);
          } else if (state is MarkAttendanceFailure) {
            setState(
              () => isProcessing = true,
            ); // Keep processing true until user dismisses
            _showErrorDialog(state.message);
          }
        },
        child: MobileScanner(
          onDetect: (capture) {
            if (isProcessing) {
              print('[QR SCANNER] Scan ignored - already processing');
              return;
            }

            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                // Prevent multiple scans immediately
                setState(() => isProcessing = true);

                final String rawCode = barcode.rawValue!;
                print('[QR SCANNER] QR code detected: $rawCode');

                try {
                  final Map<String, dynamic> data = jsonDecode(rawCode);

                  print('═══════════════════════════════════════════════════');
                  print('🔍 [QR SCANNER] QR Code Scanned Successfully!');
                  print('═══════════════════════════════════════════════════');
                  print('📦 Raw QR Code Content:');
                  print(rawCode);
                  print('───────────────────────────────────────────────────');
                  print('📋 Parsed JSON Data:');
                  print(data);
                  print('═══════════════════════════════════════════════════');

                  // Validate required fields from QR code
                  final String? qrCodeId = data['qrCodeId'];
                  final String? uuidTokenHash = data['uuidTokenHash'];
                  final String? lectureId = data['lectureId'];

                  print('🔑 Extracted Fields from QR Code:');
                  print('   ├─ qrCodeId: $qrCodeId');
                  print('   ├─ uuidTokenHash: $uuidTokenHash');
                  print('   └─ lectureId: $lectureId');
                  print('───────────────────────────────────────────────────');

                  if (qrCodeId == null || qrCodeId.isEmpty) {
                    throw const FormatException('Missing qrCodeId in QR code');
                  }

                  if (uuidTokenHash == null || uuidTokenHash.isEmpty) {
                    throw const FormatException(
                      'Missing uuidTokenHash in QR code',
                    );
                  }

                  if (lectureId == null || lectureId.isEmpty) {
                    throw const FormatException('Missing lectureId in QR code');
                  }

                  print('✅ All required fields validated successfully!');
                  print('═══════════════════════════════════════════════════');

                  final authState = context.read<AuthCubit>().state;
                  String studentId = '';
                  if (authState is AuthAuthenticated) {
                    studentId = authState.student.id;
                  }

                  print('');
                  print('👤 Student Authentication:');
                  if (studentId.isEmpty) {
                    print('   └─ ❌ ERROR: Not authenticated!');
                    print(
                      '═══════════════════════════════════════════════════',
                    );
                    throw const FormatException(
                      'Student ID not found. Please re-login.',
                    );
                  } else {
                    print('   └─ ✅ Student ID: $studentId');
                    print(
                      '═══════════════════════════════════════════════════',
                    );
                  }

                  print('🚀 Calling Develop Mark Presence API...');
                  print('');

                  context.read<MarkAttendanceCubit>().developMarkPresence(
                    lectureId,
                    studentId,
                    qrCodeId,
                  );
                  break;
                } catch (e) {
                  print('[QR SCANNER] ERROR: $e');
                  // Show error dialog directly without going through cubit
                  _showErrorDialog(
                    'كود QR غير صالح أو غير مدعوم.\n\nالخطأ: $e',
                  );
                }
              }
            }
          },
        ),
      ),
    );
  }
}
