import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  Map<String, dynamic>? _stats;
  List<dynamic> _users = [];
  Map<String, dynamic>? _analytics;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get stats => _stats;
  List<dynamic> get users => _users;
  Map<String, dynamic>? get analytics => _analytics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch platform statistics
  Future<void> fetchStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _adminService.getStats();

    if (result['success']) {
      _stats = result['stats'];
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch users
  Future<void> fetchUsers({String? role, String? search}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _adminService.getUsers(role: role, search: search);

    if (result['success']) {
      _users = result['users'];
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update user
  Future<bool> updateUser(String userId, Map<String, dynamic> data) async {
    final result = await _adminService.updateUser(userId, data);

    if (result['success']) {
      await fetchUsers(); // Refresh
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(String userId) async {
    final result = await _adminService.deleteUser(userId);

    if (result['success']) {
      _users.removeWhere((u) => u['_id'] == userId);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Verify restaurant
  Future<bool> verifyRestaurant(String restaurantId, {bool isActive = true, bool isVerified = true}) async {
    final result = await _adminService.verifyRestaurant(restaurantId, isActive: isActive, isVerified: isVerified);

    if (result['success']) {
      await fetchUsers(role: 'restaurant'); // Refresh restaurants
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Fetch analytics
  Future<void> fetchAnalytics({String period = 'month'}) async {
    _isLoading = true;
    notifyListeners();

    final result = await _adminService.getRevenueAnalytics(period: period);

    if (result['success']) {
      _analytics = result['analytics'];
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
  }
}
