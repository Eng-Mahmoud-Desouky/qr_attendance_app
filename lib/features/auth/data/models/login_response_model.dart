import 'package:json_annotation/json_annotation.dart';
import 'student_model.dart';

part 'login_response_model.g.dart';

@JsonSerializable()
class LoginResponseModel {
  final String accessToken;
  final String refreshToken;
  final StudentModel student;

  LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.student,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);
}
