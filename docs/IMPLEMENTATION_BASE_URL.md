# تنفيذ خاصية Base URL الديناميكي

## 📋 نظرة عامة
تم تنفيذ خاصية **تكوين Base URL ديناميكياً** في التطبيق، مما يسمح للمطورين بتغيير عنوان الـ API مباشرة من داخل التطبيق بدلاً من التعديل المتكرر في الكود.

## 🎯 المشكلة السابقة
- كان لازم نعدل `baseUrl` في ملف `constants.dart` في كل مرة
- Debug جديد بعد كل تعديل
- عملية مزعجة ومضيعة للوقت

## ✅ الحل الجديد
شاشة إعدادات داخل التطبيق تسمح بـ:
- إدخال Base URL يدوياً
- حفظ الـ URL محلياً على الجهاز
- استخدام الـ URL الجديد فوراً بدون إعادة تشغيل

## 🏗️ البنية المعمارية

### 1. UrlConfigService
```dart
lib/core/services/url_config_service.dart
```
**المسؤوليات:**
- إدارة وحفظ Base URL باستخدام `SharedPreferences`
- توفير القيمة الافتراضية
- تنظيف الـ URL (إزالة trailing slash)
- إعادة التعيين للقيمة الافتراضية

**الوظائف الرئيسية:**
- `getBaseUrl()`: جلب الـ URL الحالي
- `saveBaseUrl(String url)`: حفظ URL جديد
- `resetToDefault()`: إعادة التعيين
- `isUsingDefault()`: التحقق من استخدام القيمة الافتراضية

### 2. ApiConstants (معدّل)
```dart
lib/core/constants/constants.dart
```
**التغيير:**
```dart
// قبل ❌
static const String baseUrl = 'http://192.168.1.238:8083';

// بعد ✅
static String get baseUrl {
  try {
    final urlService = sl<UrlConfigService>();
    return urlService.getBaseUrl();
  } catch (e) {
    return 'http://192.168.1.238:8083'; // Fallback
  }
}
```

### 3. SettingsScreen
```dart
lib/features/settings/presentation/pages/settings_screen.dart
```
**المميزات:**
- ✨ واجهة عربية (RTL)
- 🎨 تصميم Material Design حديث
- ✅ Validation للـ URL
- 💾 حفظ تلقائي
- 📋 أمثلة للـ URLs
- 🔄 زر Reset
- 📱 Responsive UI

**المكونات:**
1. **Header Card**: معلومات عن الخاصية
2. **URL Input Field**: مع validation
3. **Current URL Display**: عرض الـ URL الحالي
4. **Action Buttons**: حفظ وإعادة تعيين
5. **Help Section**: أمثلة على URLs صحيحة

## 🔧 Dependency Injection

### التسجيل في `injection_container.dart`
```dart
// External
final sharedPreferences = await SharedPreferences.getInstance();
sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

// Core
sl.registerLazySingleton(() => UrlConfigService(sl()));
```

## 🚀 كيفية الاستخدام

### للمستخدم النهائي:
1. افتح التطبيق
2. اذهب لصفحة **Profile**
3. اضغط على أيقونة **⚙️ الإعدادات**
4. أدخل Base URL الجديد
5. اضغط **حفظ**

### للمطور:
```dart
// استخدام الـ URL في أي مكان
final url = ApiConstants.baseUrl; // يجلب القيمة الديناميكية

// الوصول للـ Service مباشرة
final urlService = sl<UrlConfigService>();
final currentUrl = urlService.getBaseUrl();
await urlService.saveBaseUrl('http://new-url:8083');
```

## 📦 Dependencies المضافة

### في `pubspec.yaml`
```yaml
dependencies:
  shared_preferences: ^2.2.2  # ✅ جديد
```

## 🎨 الواجهة

### تصميم الشاشة:
- 🎨 Material Design مع الوان متناسقة
- 📝 حقول إدخال واضحة مع placeholders
- ✅ زر حفظ بارز (Primary Button)
- 🔄 زر إعادة تعيين (Outlined Button)
- 📘 قسم مساعدة مع أمثلة
- 💡 Info box لعرض الـ URL الحالي

### الألوان والأيقونات:
- 🔵 Primary: أزرق للإجراءات الأساسية
- 🟠 Orange: للمساعدة والتنبيهات
- ⚙️ Settings Icon: للوصول للإعدادات

## ✨ مميزات إضافية

### 1. URL Validation
- ✅ التحقق من بداية `http://` أو `https://`
- ✅ التحقق من عدم وجود قيم فارغة
- ✅ رسائل خطأ واضحة

### 2. Auto-Cleanup
- إزالة المسافات (trim)
- إزالة trailing slash تلقائياً
- تنسيق موحد للـ URLs

### 3. User Feedback
- ✅ SnackBar عند النجاح (أخضر)
- ❌ SnackBar عند الفشل (أحمر)
- ⏳ Loading indicator أثناء الحفظ

### 4. Default Fallback
- إذا فشل تحميل الـ Service
- القيمة الافتراضية: `http://192.168.1.238:8083`

## 🧪 أمثلة على URLs

### Android Emulator
```
http://10.0.2.2:8083
```

### Local Network
```
http://192.168.1.100:8083
http://192.168.0.50:8080
```

### Production
```
https://api.example.com
https://api.yourcompany.com/v1
```

## 📝 ملحوظات مهمة

### ✅ يعمل
- تغيير الـ URL بدون إعادة تشغيل
- الحفظ المحلي على الجهاز
- استخدام فوري في كل الـ API calls

### ⚠️ ملاحظات
- الـ URL المحفوظ يبقى حتى بعد إلغاء تثبيت التطبيق (إذا لم يتم مسح الـ cache)
- يجب التأكد من صحة الـ URL قبل الحفظ
- الـ Dio instance يُنشأ مرة واحدة في الـ DI، لكن `baseUrl` يُقرأ ديناميكياً

## 🔍 Troubleshooting

### المشكلة: الـ URL لا يتغير
**الحل:** تأكد من:
- حفظ الـ URL بنجاح (شاهد SnackBar الأخضر)
- الـ `UrlConfigService` تم تسجيله في DI
- `flutter pub get` تم تشغيله

### المشكلة: SharedPreferences not found
**الحل:**
```bash
flutter pub get
flutter clean
flutter pub get
```

## 📊 الملفات المتأثرة

### ملفات جديدة (2)
1. `lib/core/services/url_config_service.dart`
2. `lib/features/settings/presentation/pages/settings_screen.dart`

### ملفات معدّلة (4)
1. `lib/core/constants/constants.dart`
2. `lib/injection_container.dart`
3. `lib/features/student/presentation/pages/profile_screen.dart`
4. `pubspec.yaml`

### ملفات توثيق (1)
1. `docs/BASE_URL_CONFIG.md`

## 🎯 الخلاصة

تم تنفيذ حل كامل ومتكامل لمشكلة تغيير Base URL بشكل متكرر. الحل:
- ✅ سهل الاستخدام
- ✅ آمن (validation)
- ✅ فعّال (بدون restart)
- ✅ احترافي (UI/UX ممتاز)
- ✅ موثّق بالكامل

---

**تاريخ التنفيذ:** 2025-12-17  
**الحالة:** ✅ مكتمل وجاهز للاستخدام
