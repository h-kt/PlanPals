import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planpals/features/profile/services/user_service.dart';
import '../models/user_model.dart';
import '../services/firebase_user.dart'; // Import your user model

class UserViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  final FirebaseUserService _firebaseUserService = FirebaseUserService();

  User? _firebaseUser = FirebaseAuth.instance.currentUser;
  PPUser? _user; // Cached user data
  bool _isLoading = false; // Loading state
  String? _errorMessage; // Error message

  PPUser? get currentUser => _user; // Get the current user
  bool get isLoading => _isLoading; // Get loading state
  String? get errorMessage => _errorMessage; // Get error message

  //-------------------------------------------
  // FETCH USER
  //-------------------------------------------

  Future<PPUser?> fetchUserByUserName(String userName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    PPUser? fetchedUser;

    try {
      print("USERVIEWMODEL: FETCHING USER: $userName");
      fetchedUser = await _userService.fetchUserByUserName(userName);
      print('USERVIEWMODEL: FETCHED USER: $_user');
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return fetchedUser;
  }

  // -------------------------------------------
  // ADD USER
  //-------------------------------------------

  // Add a new destination to the planner
  Future<void> addUser(PPUser user) async {
    try {
      // Call the service to add the planner
      // _user = await _userService.addUser(user);
      _firebaseUser =
          await _firebaseUserService.signUp(user.email, user.password);
      print("USERVIEWMODEL: ADDED USER: $_firebaseUser");
      // print("USERVIEWMODEL: ADDED USER AFTER: $user");

      // Notify listeners about the change in state
      notifyListeners();
    } catch (e) {
      // Handle the exception and throw an error with a meaningful message
      throw Exception('Failed to add user: $e');
    }
  }

  //-------------------------------------------
  // LOGIN LOGOUT
  //-------------------------------------------

  Future<void> login(String userName, String email, String password) async {
    PPUser? fetched = await fetchUserByUserName(userName);
    _firebaseUser = await _firebaseUserService.signIn(email, password);
    print("USERVIEWMODEL: ADDED USER: $_firebaseUser");
    _user = fetched;
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
