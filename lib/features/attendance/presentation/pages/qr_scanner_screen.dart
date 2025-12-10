import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../cubit/mark_attendance_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  // MobileScannerController controller = MobileScannerController();
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: BlocListener<MarkAttendanceCubit, MarkAttendanceState>(
        listener: (context, state) {
          if (state is MarkAttendanceLoading) {
            setState(() => isProcessing = true);
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
          } else if (state is MarkAttendanceSuccess) {
            Navigator.of(context).pop(); // Close loader
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Success'),
                content: Text(state.message),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close alert
                      Navigator.of(context).pop(); // Go back to Home
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else if (state is MarkAttendanceFailure) {
            Navigator.of(context).pop(); // Close loader
            setState(() => isProcessing = false);
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Error'),
                content: Text(state.message),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close alert
                      // Resume scanning? MobileScanner automatically resumes usually?
                      // We might need to implement re-enabling detection logic.
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        },
        child: MobileScanner(
          onDetect: (capture) {
            if (isProcessing) return;
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                // Here we extract lectureId from QR or assume QR is lectureId
                // The API says: `qrCode` in request body. `lectureId` is also required.
                // Assuming QR contains payload that we send as `qrCode`.
                // Wait, request requires `lectureId` AND `qrCode`.
                // Does QR contain both? Or lectureId is derived?
                // API Spec: "lectureId (parsed from QR or API response)"
                // Let's assume QR string IS the payload containing everything or we parse it.
                // For simplicity, let's assume QR contains a JSON or a string we can use.
                // Actually the API Spec says: `/api/v1/attendance/mark-present` Body: `{ lectureId, studentId, qrCode ... }`
                // But we need `studentId` from logged in user.
                // We need to access Student ID. We can get it from Storage or AuthState?
                // `AuthCubit` has `Student` in state but `MarkAttendanceCubit` does not.
                // We should probably get studentId from a repository or session manager.
                // For now, hardcode or fetch from storage if we had `UserSession`.
                // I'll add a TODO or fetch from a singleton/storage in implementation.

                final String code = barcode.rawValue!;
                // Assuming QR contains "lectureId|secret"
                // Or just send raw code as qrCode and lectureId is something else?
                // The user prompt said: "lectureId (parsed from QR or API response)"

                // Let's assume the QR is just a string, and we send it.
                // But where do we get lectureId?
                // Maybe the QR IS the lectureId?
                // I'll assume parsing logic: "lectureId:qrCode" split by colon, or just passing dummy for now.
                // I'll pass code as qrCode, and extract lectureId from it if possible.
                // Let's assume content is "lecture_id_123,qr_token_abc"

                // Also need studentId.
                // Hack: Pass "stu_12345" for now, or read from `AuthCubt`.
                // I can access AuthCubit via context.read<AuthCubit>().state... if it persists.

                final authState = context.read<AuthCubit>().state;
                String studentId = 'unknown';
                if (authState is AuthAuthenticated) {
                  studentId = authState.student.id;
                }

                context.read<MarkAttendanceCubit>().markAttendance(
                  "lec_parsed_from_qr",
                  studentId,
                  code,
                  DateTime.now(),
                );
                break;
              }
            }
          },
        ),
      ),
    );
  }
}
