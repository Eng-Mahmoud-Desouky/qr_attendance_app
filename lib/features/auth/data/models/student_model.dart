import '../../domain/entities/student.dart';

class StudentModel extends Student {
  const StudentModel({
    required super.id,
    required super.name,
    required super.email,
    super.enrolledCourses,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    String name = '';
    if (json['firstName'] != null || json['lastName'] != null) {
      name = '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim();
    } else {
      name = json['name'] ?? json['username'] ?? 'Unknown';
    }

    return StudentModel(
      id: json['academicMemberId'] ?? json['id'] ?? '',
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
