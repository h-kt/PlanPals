import 'dart:convert';
import 'package:planpals/shared/network/api_service.dart';
import 'package:planpals/features/profile/models/user_model.dart';

class UserService {
  final ApiService _apiService = ApiService();

  // Fetch user details by userName
  /// Fetches a user by their username.
  Future<PPUser> fetchUserByUserName(String userName) async {
    print('USERSERVICE: FETCHING USER: $userName');
    final response = await _apiService.get('/user/search?userName=$userName');

    if (response.statusCode == 200) {
      print(response.body);
      final userJson = json.decode(response.body);
      return PPUser.fromJson(userJson['data']);
    } else {
      print(response.body);
      throw Exception('Failed to load user: ${response.statusCode}');
    }
  }

  Future<PPUser> addUser(PPUser user) async {
    try {
      final response = await _apiService.post('/user', user.toJson());

      if (response.statusCode == 201) {
        final userData = json.decode(response.body);
        print('NewUser: $userData');
        return PPUser.fromJson(userData);
      } else {
        throw Exception('Failed to add user: ${response.statusCode}');
      }
    } on Exception catch (e) {
      throw Exception('Failed to add user: $e');
    }
  }
}
