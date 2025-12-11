# تحليل مشكلة: Student ID is missing

## 🔍 السبب الجذري للمشكلة:

المشكلة تحدث لأن **بيانات الطالب (`Student`) لا يتم حفظها في الـ Local Storage**. إليك السيناريو:

### ✅ ما يحدث عند تسجيل الدخول:
1. المستخدم يدخل `username` و `password`
2. الـ API يستجيب بـ `access_token` و بيانات الطالب (`student`)
3. الـ `AuthCubit` يحفظ الـ `access_token` في الـ Secure Storage ✅
4. الـ `AuthCubit` يحفظ الـ state كـ `AuthAuthenticated(student)` في الـ Memory فقط ❌

### ❌ ما يحدث بعد إعادة فتح التطبيق:
1. التطبيق يبدأ والـ `AuthCubit` يكون في حالة `AuthInitial`
2. الـ `access_token` **موجود** في الـ Secure Storage ✅
3. لكن **بيانات الطالب (Student) غير موجودة** لأنها لم تُحفظ ❌
4. عندما يحاول المستخدم مسح QR Code، لا يمكن الحصول على `studentId` لأن الـ `AuthCubit` ليس في حالة `AuthAuthenticated`
5. نفس المشكلة تحدث في صفحة الـ History

## 📍 الأماكن المتأثرة:

### 1. QR Scanner (`qr_scanner_screen.dart` - Line 195-198):
```dart
final authState = context.read<AuthCubit>().state;
String studentId = '';
if (authState is AuthAuthenticated) {
  studentId = authState.student.id;  // ❌ authState NOT AuthAuthenticated after app restart
}
```

### 2. Attendance History (`attendance_history_screen.dart` - Line 24-27):
```dart
void _loadHistory() {
  final authState = context.read<AuthCubit>().state;
  if (authState is AuthAuthenticated) {
    context.read<AttendanceHistoryCubit>().loadHistory(authState.student.id);  // ❌ Same issue
  }
}
```

### 3. Remote Data Source (`attendance_remote_data_source.dart` - Line 233-234):
```dart
if (studentId.isEmpty) {
  throw ServerException('Student ID is missing. Please re-login.');  // ❌ This error is thrown
}
```

## 🔧 الحل المطلوب:

### الخيار 1: حفظ بيانات الطالب في Local Storage (الحل الموصى به)
1. إضافة Methods في `AuthLocalDataSource`:
   - `saveStudent(Student student)`
   - `getStudent(): Student?`
   - `clearStudent()`

2. تحديث `AuthCubit`:
   - حفظ بيانات الطالب عند Login
   - إضافة Method `checkAuthStatus()` لاسترجاع البيانات عند بدء التطبيق
   - استرجاع بيانات الطالب المحفوظة إذا وُجدت

3. استدعاء `checkAuthStatus()` عند بدء التطبيق في `main.dart`

### الخيار 2: إضافة API Endpoint `/api/student/profile` (إذا لم يكن موجودًا)
- استدعاء الـ API للحصول على بيانات الطالب باستخدام الـ `access_token`
- أقل كفاءة لأنه يتطلب استدعاء API في كل مرة

## 📝 ملاحظات إضافية:

- الـ `access_token` **يتم حفظه بنجاح** ولذلك الطلبات الأخرى تعمل
- لكن بيانات الطالب **تختفي** بعد إغلاق التطبيق
- هذا يفسر لماذا المشكلة تظهر في QR Scanner و History Screen معًا

## 🎯 الخطة:
سنُنفذ **الخيار 1** لأنه الأكثر كفاءة ولا يتطلب استدعاءات API إضافية.
