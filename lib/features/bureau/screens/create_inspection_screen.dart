import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/inspection_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/inspection_model.dart';
import '../../../core/theme/colors.dart';

/// Inspection Target for Cooperatives and Farms
class InspectionTarget {
  final String id;
  final String name;
  final String woredaId;
  final String woredaName;
  final String type; // 'cooperative' or 'farm'
  final String subtitle;

  const InspectionTarget({
    required this.id,
    required this.name,
    required this.woredaId,
    required this.woredaName,
    required this.type,
    required this.subtitle,
  });
}

/// Create Inspection Screen
/// Allows bureau officers to create new inspections
/// Requirements: 4.1-4.14
class CreateInspectionScreen extends StatefulWidget {
  const CreateInspectionScreen({super.key});

  @override
  State<CreateInspectionScreen> createState() => _CreateInspectionScreenState();
}

class _CreateInspectionScreenState extends State<CreateInspectionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  InspectionType _selectedType = InspectionType.routine;
  String _targetType = 'cooperative'; // 'cooperative' or 'farm'
  String? _targetId;
  String? _targetName;
  String? _woredaId;
  String? _woredaName;
  DateTime? _scheduledDate;
  final _notesController = TextEditingController();
  final _targetController = TextEditingController();
  final _woredaController = TextEditingController();
  
  bool _isSubmitting = false;

  static const List<InspectionTarget> _allTargets = [
    // Cooperatives
    InspectionTarget(
      id: 'coop-001',
      name: 'Jimma Coffee Growers Cooperative',
      woredaId: 'woreda-001',
      woredaName: 'Jimma Town',
      type: 'cooperative',
      subtitle: '245 members • Washed & Sun-dried Arabica',
    ),
    InspectionTarget(
      id: 'coop-002',
      name: 'Oromia Agricultural Cooperative Union',
      woredaId: 'woreda-002',
      woredaName: 'Agaro',
      type: 'cooperative',
      subtitle: '189 members • Premium Grade 1 Beans',
    ),
    InspectionTarget(
      id: 'coop-003',
      name: 'Gomma Multipurpose Farmers Coop',
      woredaId: 'woreda-003',
      woredaName: 'Gomma',
      type: 'cooperative',
      subtitle: '156 members • Organic Avocado & Fruits',
    ),
    InspectionTarget(
      id: 'coop-004',
      name: 'Sidama Coffee Farmers Union',
      woredaId: 'woreda-004',
      woredaName: 'Hawassa',
      type: 'cooperative',
      subtitle: '310 members • Specialty Grade Coffee',
    ),
    InspectionTarget(
      id: 'coop-005',
      name: 'Bonga Honey & Spices Cooperative',
      woredaId: 'woreda-005',
      woredaName: 'Bonga',
      type: 'cooperative',
      subtitle: '98 members • Forest Honey & Cardamom',
    ),
    // Farms
    InspectionTarget(
      id: 'farm-001',
      name: 'Abba Jifar Demonstration Farm',
      woredaId: 'woreda-001',
      woredaName: 'Jimma Town',
      type: 'farm',
      subtitle: '12.5 Hectares • Coffee & Shade Trees',
    ),
    InspectionTarget(
      id: 'farm-002',
      name: 'Agaro Specialty Plot',
      woredaId: 'woreda-002',
      woredaName: 'Agaro',
      type: 'farm',
      subtitle: '8.0 Hectares • Hybrid Maize & Legumes',
    ),
    InspectionTarget(
      id: 'farm-003',
      name: 'Gomma Highland Organic Estate',
      woredaId: 'woreda-003',
      woredaName: 'Gomma',
      type: 'farm',
      subtitle: '5.2 Hectares • Export Quality Hass Avocado',
    ),
    InspectionTarget(
      id: 'farm-004',
      name: 'Kaffa Biosphere Reserve Farm',
      woredaId: 'woreda-005',
      woredaName: 'Bonga',
      type: 'farm',
      subtitle: '15.0 Hectares • Wild Arabica Coffee',
    ),
    InspectionTarget(
      id: 'farm-005',
      name: 'Rift Valley Commercial Plot',
      woredaId: 'woreda-004',
      woredaName: 'Hawassa',
      type: 'farm',
      subtitle: '22.0 Hectares • Teff & Sorghum',
    ),
  ];

  @override
  void dispose() {
    _notesController.dispose();
    _targetController.dispose();
    _woredaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Inspection'),
        backgroundColor: AppColors.primary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildInspectionTypeDropdown(),
            const SizedBox(height: 16),
            _buildTargetTypeSelection(),
            const SizedBox(height: 16),
            _buildTargetSearch(),
            const SizedBox(height: 16),
            _buildWoredaDisplay(),
            const SizedBox(height: 16),
            _buildScheduledDatePicker(),
            const SizedBox(height: 16),
            _buildNotesField(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectionTypeDropdown() {
    return DropdownButtonFormField<InspectionType>(
      value: _selectedType,
      decoration: const InputDecoration(
        labelText: 'Inspection Type',
        border: OutlineInputBorder(),
      ),
      items: InspectionType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.displayName),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedType = value);
        }
      },
    );
  }

  Widget _buildTargetTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Target Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Cooperative'),
                value: 'cooperative',
                groupValue: _targetType,
                onChanged: (value) {
                  if (value != null && value != _targetType) {
                    setState(() {
                      _targetType = value;
                      _targetId = null;
                      _targetName = null;
                      _woredaId = null;
                      _woredaName = null;
                      _targetController.clear();
                      _woredaController.clear();
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Farm'),
                value: 'farm',
                groupValue: _targetType,
                onChanged: (value) {
                  if (value != null && value != _targetType) {
                    setState(() {
                      _targetType = value;
                      _targetId = null;
                      _targetName = null;
                      _woredaId = null;
                      _woredaName = null;
                      _targetController.clear();
                      _woredaController.clear();
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTargetSearch() {
    return TextFormField(
      controller: _targetController,
      decoration: InputDecoration(
        labelText: _targetType == 'cooperative' 
            ? 'Select Cooperative' 
            : 'Select Farm',
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.search),
        hintText: 'Tap to search and select ${_targetType == 'cooperative' ? 'cooperative' : 'farm'}...',
      ),
      validator: (value) {
        if (_targetId == null) {
          return 'Please select a $_targetType';
        }
        return null;
      },
      onTap: _showTargetSelectionDialog,
      readOnly: true,
    );
  }

  Widget _buildWoredaDisplay() {
    if (_woredaName == null) {
      return const SizedBox.shrink();
    }
    
    return TextFormField(
      controller: _woredaController,
      decoration: const InputDecoration(
        labelText: 'Assigned Woreda',
        border: OutlineInputBorder(),
        enabled: false,
        prefixIcon: Icon(Icons.location_on_outlined),
      ),
      readOnly: true,
    );
  }

  Widget _buildScheduledDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        
        if (date != null) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          
          if (time != null) {
            setState(() {
              _scheduledDate = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
            });
          }
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Scheduled Date & Time (Optional)',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          _scheduledDate == null
              ? 'Tap to select'
              : '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year} ${_scheduledDate!.hour}:${_scheduledDate!.minute.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Initial Notes (Optional)',
        border: OutlineInputBorder(),
        hintText: 'Add any initial observations or notes...',
      ),
      maxLines: 4,
      maxLength: 500,
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _handleSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: _isSubmitting
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              'Create Inspection',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final inspectionProvider = context.read<InspectionProvider>();

    // Validate woreda authorization
    final assignedWoredas = authProvider.user?.roleData?['assignedWoredas'] as List?;
    if (assignedWoredas != null && !assignedWoredas.contains(_woredaId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are not authorized for this woreda'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final data = {
      'type': _selectedType.name,
      'officerId': authProvider.user?.id ?? 'officer-001',
      'officerName': authProvider.user?.fullName ?? 'Bureau Officer',
      if (_targetType == 'cooperative') 'cooperativeId': _targetId,
      if (_targetType == 'cooperative') 'cooperativeName': _targetName,
      if (_targetType == 'farm') 'farmId': _targetId,
      if (_targetType == 'farm') 'farmName': _targetName,
      'woredaId': _woredaId,
      'woredaName': _woredaName,
      if (_scheduledDate != null) 'scheduledDate': _scheduledDate!.toIso8601String(),
      'notes': _notesController.text,
      'status': 'scheduled',
    };

    final inspection = await inspectionProvider.createInspection(data);

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (inspection != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inspection created successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(inspection);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(inspectionProvider.error ?? 'Failed to create inspection'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showTargetSelectionDialog() {
    final typeLabel = _targetType == 'cooperative' ? 'Cooperative' : 'Farm';
    final availableTargets = _allTargets.where((t) => t.type == _targetType).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = availableTargets.where((target) {
              if (searchQuery.isEmpty) return true;
              final q = searchQuery.toLowerCase();
              return target.name.toLowerCase().contains(q) ||
                  target.woredaName.toLowerCase().contains(q) ||
                  target.subtitle.toLowerCase().contains(q);
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select $typeLabel',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        autofocus: false,
                        decoration: InputDecoration(
                          hintText: 'Search $typeLabel or woreda...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          isDense: true,
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            searchQuery = val;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Text('No $typeLabel found matching "$searchQuery"'),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                itemCount: filtered.length,
                                separatorBuilder: (context, index) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final target = filtered[index];
                                  final isSelected = target.id == _targetId;
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: isSelected
                                          ? AppColors.primary
                                          : AppColors.primary.withValues(alpha: 0.1),
                                      child: Icon(
                                        _targetType == 'cooperative'
                                            ? Icons.groups_outlined
                                            : Icons.agriculture_outlined,
                                        color: isSelected ? Colors.white : AppColors.primary,
                                      ),
                                    ),
                                    title: Text(
                                      target.name,
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text('${target.woredaName} • ${target.subtitle}'),
                                    trailing: isSelected
                                        ? const Icon(Icons.check_circle, color: AppColors.primary)
                                        : null,
                                    onTap: () {
                                      setState(() {
                                        _targetId = target.id;
                                        _targetName = target.name;
                                        _woredaId = target.woredaId;
                                        _woredaName = target.woredaName;
                                        _targetController.text = target.name;
                                        _woredaController.text = '${target.woredaName} (${target.woredaId})';
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
