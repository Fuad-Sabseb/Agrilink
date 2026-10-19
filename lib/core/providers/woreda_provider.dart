import 'package:flutter/foundation.dart';
import '../models/woreda_model.dart';
import '../services/woreda_service.dart';

class WoredaProvider extends ChangeNotifier {
  final WoredaService _woredaService = WoredaService();

  List<WoredaModel> _assignedWoredas = [];
  WoredaModel? _selectedWoreda;
  bool _isLoading = false;
  String? _error;

  List<WoredaModel> get assignedWoredas => _assignedWoredas;
  WoredaModel? get selectedWoreda => _selectedWoreda;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMultipleWoredas => _assignedWoredas.length > 1;

  /// Fetch assigned woredas for the current user (bureau officers)
  Future<void> fetchAssignedWoredas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _assignedWoredas = await _woredaService.getAssignedWoredas();
      
      // Auto-select first woreda if none selected
      if (_selectedWoreda == null && _assignedWoredas.isNotEmpty) {
        _selectedWoreda = _assignedWoredas.first;
      }
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to fetch assigned woredas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Switch to a different woreda
  Future<bool> switchWoreda(String woredaId) async {
    final woreda = _assignedWoredas.firstWhere(
      (w) => w.id == woredaId,
      orElse: () => throw Exception('Woreda not found in assigned list'),
    );

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _woredaService.switchWoreda(woredaId);
      _selectedWoreda = woreda;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to switch woreda: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set selected woreda (for local state management)
  void setSelectedWoreda(WoredaModel woreda) {
    if (_assignedWoredas.contains(woreda)) {
      _selectedWoreda = woreda;
      notifyListeners();
    }
  }

  /// Clear woreda state (for logout)
  void clear() {
    _assignedWoredas = [];
    _selectedWoreda = null;
    _error = null;
    notifyListeners();
  }

  /// Retry fetching woredas after error
  Future<void> retry() async {
    await fetchAssignedWoredas();
  }
}
