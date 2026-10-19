import '../models/woreda_model.dart';
import '../network/api_client.dart';

class WoredaService {
  final ApiClient _apiClient = ApiClient();

  /// Get list of woredas assigned to current bureau officer
  Future<List<WoredaModel>> getAssignedWoredas() async {
    try {
      final response = await _apiClient.get('/users/assigned-woredas');
      
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => WoredaModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch assigned woredas: $e');
    }
  }

  /// Switch active woreda context for bureau officer
  Future<void> switchWoreda(String woredaId) async {
    try {
      await _apiClient.post(
        '/users/switch-woreda',
        data: {'woredaId': woredaId},
      );
    } catch (e) {
      if (e.toString().contains('403') || e.toString().contains('Forbidden')) {
        throw Exception('You are not authorized to access this woreda');
      }
      throw Exception('Failed to switch woreda: $e');
    }
  }

  /// Get all woredas in the system (for admin/reference)
  Future<List<WoredaModel>> getAllWoredas() async {
    try {
      final response = await _apiClient.get('/woredas');
      
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => WoredaModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch woredas: $e');
    }
  }
}
