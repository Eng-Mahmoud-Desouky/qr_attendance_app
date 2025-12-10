import '../../../../core/network/api_client.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../auth/data/models/student_model.dart';
import 'package:dio/dio.dart';

abstract class StudentRemoteDataSource {
  Future<StudentModel> getProfile();
}

class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final ApiClient client;

  StudentRemoteDataSourceImpl({required this.client});

  @override
  Future<StudentModel> getProfile() async {
    try {
      final response = await client.get(ApiConstants.profileEndpoint);
      return StudentModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? e.message ?? 'Unknown error',
      );
    }
  }
}
