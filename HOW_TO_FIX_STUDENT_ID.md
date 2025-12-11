# How to Fix the Student ID Issue

## Problem

The student ID is empty because the login API response uses a different field name than what the code expects.

## Current Code

The `StudentModel.fromJson()` method tries these fields in order:
```dart
id: json['academicMemberId'] ??
    json['studentAcademicMemberId'] ??
    json['studentId'] ??
    json['id'] ??
    ''
```

If none of these fields exist in the API response, the ID will be empty.

## How to Fix

### Step 1: Identify the Correct Field Name

Run the app and login. Look at the console logs for this section:

```
═══════════════════════════════════════════════════
🔄 [STUDENT MODEL] Parsing Student from JSON
═══════════════════════════════════════════════════
📦 Raw JSON Data:
{firstName: John, lastName: Doe, email: john@example.com, ...}
───────────────────────────────────────────────────
🔍 Checking ID fields:
   ├─ academicMemberId: null
   ├─ studentAcademicMemberId: null
   ├─ studentId: null
   └─ id: null
```

Look at the "Raw JSON Data" and find which field contains the student's UUID.

**Common field names to look for:**
- `memberId`
- `userId`
- `studentMemberId`
- `academicId`
- `uuid`
- `_id`
- Or any other field that contains a UUID value

### Step 2: Update the Code

Once you identify the correct field name (let's say it's `memberId`), update the code:

**File**: `lib/features/auth/data/models/student_model.dart`

**Find this code** (around line 33):
```dart
final extractedId =
    json['academicMemberId'] ??
    json['studentAcademicMemberId'] ??
    json['studentId'] ??
    json['id'] ??
    '';
```

**Replace with** (add your field name at the top):
```dart
final extractedId =
    json['memberId'] ??  // <-- ADD YOUR FIELD NAME HERE
    json['academicMemberId'] ??
    json['studentAcademicMemberId'] ??
    json['studentId'] ??
    json['id'] ??
    '';
```

### Step 3: Update the toJson Method

Also update the `toJson()` method to save with the correct field name:

**File**: `lib/features/auth/data/models/student_model.dart`

**Find this code** (around line 59):
```dart
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'name': name,
    'email': email,
    'enrolledCourses': enrolledCourses,
  };
}
```

**Keep it as is** - The `toJson()` method is used for local storage, so we can keep using `'id'` as the key.

### Step 4: Test

1. **Logout** from the app (to clear old data)
2. **Login** again
3. Check the logs - you should now see:
   ```
   🎯 Extracted Values:
      ├─ ID: <uuid-value-here>
      ├─ Name: John Doe
      └─ Email: john@example.com
   ```
4. Navigate to "Attendance History"
5. You should now see the API request being made with the student ID

## Example Scenarios

### Scenario 1: Field is named `memberId`

```dart
final extractedId =
    json['memberId'] ??
    json['academicMemberId'] ??
    json['studentAcademicMemberId'] ??
    json['studentId'] ??
    json['id'] ??
    '';
```

### Scenario 2: Field is nested (e.g., `user.id`)

If the ID is nested like this:
```json
{
  "user": {
    "id": "uuid-here",
    "name": "John"
  }
}
```

Then you need to access it differently:
```dart
final extractedId =
    json['user']?['id'] ??
    json['academicMemberId'] ??
    json['studentAcademicMemberId'] ??
    json['studentId'] ??
    json['id'] ??
    '';
```

### Scenario 3: Field uses camelCase differently

If the field is `academic_member_id` (snake_case):
```dart
final extractedId =
    json['academic_member_id'] ??
    json['academicMemberId'] ??
    json['studentAcademicMemberId'] ??
    json['studentId'] ??
    json['id'] ??
    '';
```

## Verification

After making the change, the logs should show:

```
✅ [AUTH API] Parsed Login Response
═══════════════════════════════════════════════════
🎫 Access Token: eyJhbGciOiJIUzI1NiIs...
👤 Student ID: 12345678-1234-1234-1234-123456789abc  <-- NOT EMPTY!
👤 Student Name: John Doe
👤 Student Email: john@example.com
```

And when loading history:

```
📱 [HISTORY SCREEN] Loading History
═══════════════════════════════════════════════════
✅ User is authenticated
   ├─ Student ID: 12345678-1234-1234-1234-123456789abc  <-- NOT EMPTY!
   ├─ Student Name: John Doe
   └─ Student Email: john@example.com
```

## Need Help?

If you're still having issues, share the complete "Raw JSON Data" from the login response logs, and I can help you identify the correct field name.

