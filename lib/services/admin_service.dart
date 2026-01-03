import 'api_service.dart';
import '../config/constants.dart';

class AdminService {
  final ApiService _apiService = ApiService();

  // Get platform statistics
  Future<Map<String, dynamic>> getStats({String? startDate, String? endDate}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response = await _apiService.get(
        '/api/admin/stats',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success']) {
        return {'success': true, 'stats': response.data['data']};
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to load stats'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get all users
  Future<Map<String, dynamic>> getUsers({String? role, String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (role != null) queryParams['role'] = role;
      if (search != null) queryParams['search'] = search;

      final response = await _apiService.get(
        '/api/admin/users',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success']) {
        return {'success': true, 'users': response.data['data']};
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to load users'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Update user
  Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put(
        '/api/admin/users/$userId',
        data: data,
      );

      if (response.statusCode == 200 && response.data['success']) {
        return {'success': true, 'user': response.data['data']};
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to update user'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Delete user
  Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      final response = await _apiService.delete('/api/admin/users/$userId');

      if (response.statusCode == 200 && response.data['success']) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to delete user'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Verify restaurant
  Future<Map<String, dynamic>> verifyRestaurant(String restaurantId) async {
    try {
      final response = await _apiService.put(
        '/api/admin/restaurants/$restaurantId/verify',
      );

      if (response.statusCode == 200 && response.data['success']) {
        return {'success': true, 'restaurant': response.data['data']};
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to verify restaurant'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get revenue analytics
  Future<Map<String, dynamic>> getRevenueAnalytics({String period = 'month'}) async {
    try {
      final response = await _apiService.get(
        '/api/admin/analytics/revenue',
        queryParameters: {'period': period},
      );

      if (response.statusCode == 200 && response.data['success']) {
        return {'success': true, 'analytics': response.data['data']};
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to load analytics'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
