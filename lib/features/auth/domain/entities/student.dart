import 'package:equatable/equatable.dart';

class Student extends Equatable {
  final String id;
  final String name;
  final String email;
  final List<String> enrolledCourses;

  const Student({
    required this.id,
    required this.name,
    required this.email,
    this.enrolledCourses = const [],
  });

  @override
  List<Object> get props => [id, name, email, enrolledCourses];
}
