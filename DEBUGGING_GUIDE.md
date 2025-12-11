# QR Attendance App - Debugging Guide

## Issues Addressed

This guide helps debug two critical issues:
1. **Attendance History not loading** - No API requests being sent to server
2. **QR Code Scanning not working** - No API requests being sent to server

## Root Cause Identified

**The Student ID is EMPTY!** This is why no API requests are being made. The logs show:
```
I/flutter ( 8720):    ├─ Student ID:
I/flutter ( 8720): ❌ [HISTORY API] Student ID is empty!
```

This means the login response is not providing the student ID in the expected format.

## Changes Made

### 1. Enhanced Logging Throughout the App

#### Files Modified:
- `lib/features/auth/data/datasources/auth_remote_data_source.dart` - **NEW: Login response logging**
- `lib/features/auth/data/models/student_model.dart` - **NEW: Student parsing logging**
- `lib/features/attendance/presentation/cubit/attendance_history_cubit.dart`
- `lib/features/attendance/data/datasources/attendance_remote_data_source.dart`
- `lib/features/attendance/presentation/pages/attendance_history_screen.dart`
- `lib/core/network/api_client.dart`
- `lib/core/network/auth_interceptor.dart`

### 2. Fixed API Client Issues

**Problem**: The `ApiClient` was adding duplicate token interceptors, which could interfere with the `AuthInterceptor` from dependency injection.

**Solution**: Removed the duplicate token reading logic from `ApiClient` and kept only the logging interceptors.

## How to Test

### Step 1: Run the App

```bash
# For Android
flutter run -d <your-android-device>

# For iOS
flutter run -d <your-ios-device>

# For Web
flutter run -d chrome

# For Linux
flutter run -d linux
```

### Step 2: Login

1. Open the app
2. Login with valid credentials
3. **IMPORTANT**: Watch the console for the login response structure

**Expected logs:**
```
═══════════════════════════════════════════════════
🔐 [AUTH API] Login Request
═══════════════════════════════════════════════════
👤 Username: <your-username>
═══════════════════════════════════════════════════

═══════════════════════════════════════════════════
✅ [AUTH API] Login Response Received
═══════════════════════════════════════════════════
📦 Raw Response Data:
{access_token: eyJhbGci..., user: {...}}
───────────────────────────────────────────────────
🔍 Response Data Type: _Map<String, dynamic>
═══════════════════════════════════════════════════

═══════════════════════════════════════════════════
🔄 [STUDENT MODEL] Parsing Student from JSON
═══════════════════════════════════════════════════
📦 Raw JSON Data:
{firstName: John, lastName: Doe, email: john@example.com, ...}
───────────────────────────────────────────────────
🔍 Checking ID fields:
   ├─ academicMemberId: <uuid or null>
   ├─ studentAcademicMemberId: <uuid or null>
   ├─ studentId: <uuid or null>
   └─ id: <uuid or null>
───────────────────────────────────────────────────
🎯 Extracted Values:
   ├─ ID: <should-be-a-uuid-NOT-EMPTY>
   ├─ Name: John Doe
   └─ Email: john@example.com
═══════════════════════════════════════════════════

═══════════════════════════════════════════════════
📋 [AUTH API] Parsed Login Response
═══════════════════════════════════════════════════
🎫 Access Token: eyJhbGciOiJIUzI1NiIs...
👤 Student ID: <should-be-a-uuid-NOT-EMPTY>
👤 Student Name: John Doe
👤 Student Email: john@example.com
═══════════════════════════════════════════════════
```

### ⚠️ CRITICAL CHECK:

**Look at the "Checking ID fields" section!**

If ALL four fields show `null`:
```
🔍 Checking ID fields:
   ├─ academicMemberId: null
   ├─ studentAcademicMemberId: null
   ├─ studentId: null
   └─ id: null
```

**This means the API response uses a DIFFERENT field name for the student ID!**

**ACTION REQUIRED:**
1. Look at the "Raw JSON Data" section
2. Find which field contains the student's UUID
3. Update `StudentModel.fromJson()` to use that field name

### Step 3: Test Attendance History

1. Navigate to "Attendance History" from the home screen
2. Watch the console for detailed logs

**Expected log flow:**
```
═══════════════════════════════════════════════════
📱 [HISTORY SCREEN] Loading History
═══════════════════════════════════════════════════
🔍 Auth State: AuthAuthenticated
✅ User is authenticated
   ├─ Student ID: <uuid>
   ├─ Student Name: <name>
   └─ Student Email: <email>
═══════════════════════════════════════════════════
🚀 Calling loadHistory with student ID: <uuid>

═══════════════════════════════════════════════════
📋 [HISTORY CUBIT] Loading Attendance History
═══════════════════════════════════════════════════
🎯 Parameters:
   ├─ Student ID: <uuid>
   ├─ Limit: 50
   └─ Offset: 0
═══════════════════════════════════════════════════

[AUTH INTERCEPTOR] 🔐 Processing request to: /api/v1/attendance/find-student-history
[AUTH INTERCEPTOR] ✅ Token added to request
[AUTH INTERCEPTOR] 🎫 Token preview: eyJhbGciOiJIUzI1NiIs...

[API CLIENT] 📤 GET Request to: /api/v1/attendance/find-student-history
[API CLIENT] 🔍 Query Params: {studentId: <uuid>, limit: 50}

═══════════════════════════════════════════════════
📤 [HISTORY API] Fetching Attendance History
═══════════════════════════════════════════════════
🎯 Request Information:
   ├─ Endpoint: /api/v1/attendance/find-student-history
   ├─ Method: GET
   ├─ Student ID: <uuid>
   ├─ Limit: 50
   └─ Offset: 0
═══════════════════════════════════════════════════
🚀 Sending GET request...

[API CLIENT] ✅ Response from: /api/v1/attendance/find-student-history
[API CLIENT] 📊 Status Code: 200

✅ [HISTORY CUBIT] Successfully loaded history
   └─ Records count: <number>
```

### Step 4: Test QR Code Scanning

1. Navigate to "Mark Attendance (QR)" from the home screen
2. Scan a valid QR code
3. Watch the console for detailed logs

**Expected log flow:**
```
🔍 [QR SCANNER] QR code detected: <qr-data>
═══════════════════════════════════════════════════
🔍 [QR SCANNER] QR Code Scanned Successfully!
═══════════════════════════════════════════════════
📦 Raw QR Code Content: <json-string>
───────────────────────────────────────────────────
📋 Parsed JSON Data: {qrCodeId: <uuid>, uuidTokenHash: <hash>, lectureId: <uuid>}
═══════════════════════════════════════════════════
🚀 Calling Develop Mark Presence API...

[CUBIT] Develop mark presence triggered: lectureId=<uuid>, studentId=<uuid>, qrCodeId=<uuid>

[AUTH INTERCEPTOR] 🔐 Processing request to: /api/v1/attendance/develop-mark-present
[AUTH INTERCEPTOR] ✅ Token added to request

═══════════════════════════════════════════════════
📤 [DEVELOP ATTENDANCE] Mark Presence Request
═══════════════════════════════════════════════════
🎯 Request Information:
   ├─ Endpoint: /api/v1/attendance/develop-mark-present
   ├─ Method: PUT
   ├─ Lecture ID: <uuid>
   ├─ Student ID: <uuid>
   └─ QR Code ID: <uuid>
═══════════════════════════════════════════════════
🚀 Sending request...
```

## Troubleshooting

### Issue: No logs appear at all

**Possible causes:**
- App not running in debug mode
- Console output not visible

**Solution:**
- Run with `flutter run -v` for verbose output
- Check your IDE's debug console

### Issue: "No token found in storage" message

**Possible causes:**
- User not logged in
- Token expired or cleared

**Solution:**
- Logout and login again
- Check if login is successful

### Issue: API request fails with 401 Unauthorized

**Possible causes:**
- Token expired
- Invalid token

**Solution:**
- Logout and login again with valid credentials

### Issue: Student ID is empty

**Possible causes:**
- Login response doesn't contain student ID
- Student model parsing issue

**Solution:**
- Check the login response format
- Verify `StudentModel.fromJson()` is parsing correctly

## Next Steps

After running the app with these enhanced logs, you should be able to see:

1. **If API requests are being made** - Look for `[API CLIENT]` and `[AUTH INTERCEPTOR]` logs
2. **What data is being sent** - Check the query parameters and request body
3. **What responses are received** - Check the response status codes and data
4. **Where the flow breaks** - Identify which component is not executing

Share the console output to get more specific help with the issues.

