# Potential Issues to Check

Based on the code analysis, here are specific things to verify when testing:

## 1. Authentication & Token Issues

### Check if token is being stored correctly after login

**Location**: `lib/features/auth/data/datasources/auth_local_data_source.dart`

**What to verify:**
- After login, check if token is saved with key `'ACCESS_TOKEN'`
- Check if student data is saved with key `'STUDENT_DATA'`

**How to verify:**
```
Look for logs:
[AUTH CUBIT] Found stored credentials
[AUTH CUBIT] Token: eyJhbGci...
[AUTH CUBIT] Student ID: <uuid>
```

**If missing:**
- Login might not be saving the token
- Check `AuthLocalDataSourceImpl.saveAccessToken()` is being called

## 2. Student ID Format Issues

### Check if student ID is being parsed correctly

**Location**: `lib/features/auth/data/models/student_model.dart`

**What to verify:**
The student ID is extracted from multiple possible fields:
```dart
id: json['academicMemberId'] ??
    json['studentAcademicMemberId'] ??
    json['studentId'] ??
    json['id'] ??
    ''
```

**How to verify:**
```
Look for logs:
[HISTORY SCREEN] Student ID: <should-be-a-uuid>
```

**If empty or wrong:**
- The login response might use a different field name
- Check the actual login response JSON structure
- Update `StudentModel.fromJson()` to match the API response

## 3. API Endpoint Issues

### Check if the correct endpoints are being used

**Current endpoints** (from `lib/core/constants/constants.dart`):
- History: `/api/v1/attendance/find-student-history`
- Mark Attendance: `/api/v1/attendance/mark-present`
- Develop Mark: `/api/v1/attendance/develop-mark-present`

**What to verify:**
- These endpoints match your backend API
- The HTTP methods are correct (GET for history, PUT for marking)

**How to verify:**
```
Look for logs:
[HISTORY API] Endpoint: /api/v1/attendance/find-student-history
[DEVELOP ATTENDANCE] Endpoint: /api/v1/attendance/develop-mark-present
```

**If wrong:**
- Update `lib/core/constants/constants.dart` with correct endpoints

## 4. Network Connectivity Issues

### Check if the app can reach the server

**Base URL**: `https://smart-attendance-system-production-253e.up.railway.app`

**What to verify:**
- The server is running and accessible
- No firewall or network issues
- HTTPS certificate is valid

**How to verify:**
```
Look for logs:
[API CLIENT] ✅ Response from: <endpoint>
[API CLIENT] 📊 Status Code: 200
```

**If failing:**
- Check server logs to see if requests are arriving
- Try accessing the API directly with curl or Postman
- Check for CORS issues (if running on web)

## 5. BLoC Provider Issues

### Check if cubits are accessible in the widget tree

**Location**: `lib/main.dart`

**What to verify:**
All cubits are provided at the root level:
```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => di.sl<AuthCubit>()),
    BlocProvider(create: (_) => di.sl<MarkAttendanceCubit>()),
    BlocProvider(create: (_) => di.sl<AttendanceHistoryCubit>()),
    BlocProvider(create: (_) => di.sl<StudentCubit>()),
  ],
  ...
)
```

**How to verify:**
```
If you see errors like:
"BlocProvider.of() called with a context that does not contain a Bloc"
```

**If failing:**
- The cubits are provided at root, so this should work
- Make sure you're using `context.read<>()` not creating new instances

## 6. QR Code Format Issues

### Check if QR codes have the expected format

**Expected format**:
```json
{
  "qrCodeId": "uuid-string",
  "uuidTokenHash": "hash-string",
  "lectureId": "uuid-string"
}
```

**How to verify:**
```
Look for logs:
[QR SCANNER] QR Code Scanned Successfully!
📋 Parsed JSON Data: {qrCodeId: ..., uuidTokenHash: ..., lectureId: ...}
```

**If failing:**
- QR code might have different format
- Check what the actual QR code contains
- Update parsing logic in `qr_scanner_screen.dart`

## 7. Dependency Injection Issues

### Check if all dependencies are registered correctly

**Location**: `lib/injection_container.dart`

**What to verify:**
- All services are registered
- No circular dependencies
- Correct singleton vs factory registration

**How to verify:**
```
If you see errors like:
"GetIt: Object/factory with type X is not registered"
```

**If failing:**
- Check `injection_container.dart` for missing registrations
- Make sure `init()` is called before `runApp()`

## 8. Response Parsing Issues

### Check if API responses match expected format

**For History** (expected):
```json
[
  {
    "attendanceId": "uuid",
    "checkInTime": "2024-01-01T10:00:00Z",
    "present": true,
    "lectureId": "uuid",
    "studentAcademicMemberId": "uuid"
  }
]
```

**How to verify:**
```
Look for logs:
[HISTORY API] Response Data: [...]
✅ [HISTORY API] Successfully parsed X records
```

**If failing:**
- Response format might be different
- Update `AttendanceRecordModel.fromJson()` to match actual response

## Quick Checklist

Run through this checklist when testing:

- [ ] App starts without errors
- [ ] Login works and shows success
- [ ] Token is stored (check logs)
- [ ] Student ID is not empty (check logs)
- [ ] Navigate to History screen
- [ ] See `[HISTORY SCREEN]` logs
- [ ] See `[AUTH INTERCEPTOR]` logs with token
- [ ] See `[API CLIENT]` logs with request
- [ ] See `[HISTORY API]` logs with response
- [ ] Navigate to QR Scanner
- [ ] Scan a QR code
- [ ] See `[QR SCANNER]` logs with parsed data
- [ ] See `[AUTH INTERCEPTOR]` logs with token
- [ ] See `[API CLIENT]` logs with request
- [ ] See `[DEVELOP ATTENDANCE]` logs with response

If any step fails, note which logs are missing - that's where the issue is!

