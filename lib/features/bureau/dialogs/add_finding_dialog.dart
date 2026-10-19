import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/inspection_model.dart';
import '../../../core/theme/colors.dart';

/// Add Finding Dialog
/// Allows bureau officers to add findings during inspections
/// Requirements: 5.4-5.9, 7.5-7.9
class AddFindingDialog extends StatefulWidget {
  final InspectionFinding? finding; // If editing existing finding

  const AddFindingDialog({
    super.key,
    this.finding,
  });

  @override
  State<AddFindingDialog> createState() => _AddFindingDialogState();
}

class _AddFindingDialogState extends State<AddFindingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _recommendationController = TextEditingController();

  String _selectedCategory = 'Crop Quality';
  FindingSeverity _selectedSeverity = FindingSeverity.minor;

  final List<String> _categories = [
    'Crop Quality',
    'Storage',
    'Documentation',
    'Safety',
    'Compliance',
    'Equipment',
    'Infrastructure',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.finding != null) {
      _selectedCategory = widget.finding!.category;
      _descriptionController.text = widget.finding!.description;
      _selectedSeverity = widget.finding!.severity;
      _recommendationController.text = widget.finding!.recommendation ?? '';
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _recommendationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildCategoryDropdown(),
                    const SizedBox(height: 16),
                    _buildDescriptionField(),
                    const SizedBox(height: 16),
                    _buildSeveritySelection(),
                    const SizedBox(height: 16),
                    _buildRecommendationField(),
                    const SizedBox(height: 24),
                    _buildActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            widget.finding == null ? 'Add Finding' : 'Edit Finding',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedCategory = value);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a category';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
        hintText: 'Describe the finding in detail...',
      ),
      maxLines: 4,
      maxLength: 500,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Description is required';
        }
        if (value.trim().length < 10) {
          return 'Description must be at least 10 characters';
        }
        return null;
      },
    );
  }

  Widget _buildSeveritySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Severity',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: FindingSeverity.values.map((severity) {
            final isSelected = _selectedSeverity == severity;
            return ChoiceChip(
              label: Text(
                severity.displayName,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSelected,
              selectedColor: _getSeverityColor(severity),
              backgroundColor: _getSeverityColor(severity).withOpacity(0.2),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedSeverity = severity);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecommendationField() {
    return TextFormField(
      controller: _recommendationController,
      decoration: const InputDecoration(
        labelText: 'Recommendation (Optional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.lightbulb_outline),
        hintText: 'Suggest corrective actions...',
      ),
      maxLines: 3,
      maxLength: 300,
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            widget.finding == null ? 'Add Finding' : 'Update Finding',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final finding = InspectionFinding(
      id: widget.finding?.id ?? const Uuid().v4(),
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      severity: _selectedSeverity,
      recommendation: _recommendationController.text.trim().isEmpty
          ? null
          : _recommendationController.text.trim(),
      timestamp: widget.finding?.timestamp ?? DateTime.now(),
    );

    Navigator.of(context).pop(finding);
  }

  Color _getSeverityColor(FindingSeverity severity) {
    switch (severity) {
      case FindingSeverity.critical:
        return AppColors.error;
      case FindingSeverity.major:
        return AppColors.secondary;
      case FindingSeverity.moderate:
        return AppColors.accent;
      case FindingSeverity.minor:
        return AppColors.warning;
    }
  }
}
