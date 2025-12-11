import '../../domain/entities/student.dart';

class StudentModel extends Student {
  const StudentModel({
    required super.id,
    required super.name,
    required super.email,
    super.enrolledCourses,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    print('');
    print('═══════════════════════════════════════════════════');
    print('🔄 [STUDENT MODEL] Parsing Student from JSON');
    print('═══════════════════════════════════════════════════');
    print('📦 Raw JSON Data:');
    print(json);
    print('───────────────────────────────────────────────────');
    print('🔍 Checking ID fields:');
    print('   ├─ userId: ${json['userId']}');
    print('   ├─ academicMemberId: ${json['academicMemberId']}');
    print('   ├─ studentAcademicMemberId: ${json['studentAcademicMemberId']}');
    print('   ├─ studentId: ${json['studentId']}');
    print('   └─ id: ${json['id']}');
    print('───────────────────────────────────────────────────');

    String name = '';
    if (json['firstName'] != null || json['lastName'] != null) {
      name = '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim();
    } else {
      name = json['name'] ?? json['username'] ?? 'Unknown';
    }

    final extractedId =
        json['userId'] ??
        json['academicMemberId'] ??
        json['studentAcademicMemberId'] ??
        json['studentId'] ??
        json['id'] ??
        '';

    print('🎯 Extracted Values:');
    print('   ├─ ID: $extractedId');
    print('   ├─ Name: $name');
    print('   └─ Email: ${json['email'] ?? ''}');
    print('═══════════════════════════════════════════════════');
    print('');

    return StudentModel(
      id: extractedId,
      name: name,
      email: json['email'] ?? '',
      enrolledCourses:
          (json['enrolledCourses'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'enrolledCourses': enrolledCourses,
    };
  }
}
