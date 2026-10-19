import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/farm_model.dart';
import '../../../core/theme/colors.dart';
import '../../../core/localization/app_localizations.dart';

class AddFarmDialog extends StatefulWidget {
  final Farm? farm; // If provided, edit mode; otherwise create mode

  const AddFarmDialog({super.key, this.farm});

  @override
  State<AddFarmDialog> createState() => _AddFarmDialogState();
}

class _AddFarmDialogState extends State<AddFarmDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _woredaController = TextEditingController();
  final _kebeleController = TextEditingController();
  final _hectaresController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.farm != null;
    
    if (_isEditMode) {
      _nameController.text = widget.farm!.farmName;
      _woredaController.text = widget.farm!.woreda;
      _kebeleController.text = widget.farm!.kebele;
      _hectaresController.text = widget.farm!.totalHectares.toStringAsFixed(2);
      _latitudeController.text = widget.farm!.latitude.toStringAsFixed(6);
      _longitudeController.text = widget.farm!.longitude.toStringAsFixed(6);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _woredaController.dispose();
    _kebeleController.dispose();
    _hectaresController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final farm = Farm(
      id: _isEditMode ? widget.farm!.id : DateTime.now().toString(),
      farmerId: _isEditMode ? widget.farm!.farmerId : 'current_farmer_id',
      farmName: _nameController.text.trim(),
      woreda: _woredaController.text.trim(),
      kebele: _kebeleController.text.trim(),
      totalHectares: double.tryParse(_hectaresController.text) ?? 0.0,
      latitude: double.tryParse(_latitudeController.text) ?? 0.0,
      longitude: double.tryParse(_longitudeController.text) ?? 0.0,
      cropPlots: _isEditMode ? widget.farm!.cropPlots : [],
      createdAt: _isEditMode ? widget.farm!.createdAt : DateTime.now(),
    );

    Navigator.of(context).pop(farm);
  }

  void _handleGetCurrentLocation() {
    // TODO: Implement GPS location fetching
    // For now, show a placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).gpsFeatureComingSoon),
        backgroundColor: AppColors.info,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.agriculture,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isEditMode ? l10n.editFarm : l10n.addFarm,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Farm Name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.farmName,
                      hintText: l10n.enterFarmName,
                      prefixIcon: const Icon(Icons.label),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.farmNameRequired;
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  // Woreda
                  TextFormField(
                    controller: _woredaController,
                    decoration: InputDecoration(
                      labelText: 'Woreda',
                      hintText: 'Enter woreda name',
                      prefixIcon: const Icon(Icons.location_city),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Woreda is required';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  // Kebele
                  TextFormField(
                    controller: _kebeleController,
                    decoration: InputDecoration(
                      labelText: 'Kebele',
                      hintText: 'Enter kebele name',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Kebele is required';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  // Total Hectares
                  TextFormField(
                    controller: _hectaresController,
                    decoration: InputDecoration(
                      labelText: l10n.totalHectares,
                      hintText: '5.0',
                      prefixIcon: const Icon(Icons.landscape),
                      suffixText: 'ha',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d*'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Total hectares is required';
                      }
                      final hectares = double.tryParse(value);
                      if (hectares == null || hectares <= 0) {
                        return 'Must be a positive number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // GPS Coordinates Section
                  Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.gpsCoordinates,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _handleGetCurrentLocation,
                        icon: const Icon(Icons.gps_fixed, size: 18),
                        label: Text(l10n.getCurrentLocation),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Latitude
                      Expanded(
                        child: TextFormField(
                          controller: _latitudeController,
                          decoration: InputDecoration(
                            labelText: l10n.latitude,
                            hintText: '7.6802',
                            prefixIcon: const Icon(Icons.straighten),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^-?\d*\.?\d*'),
                            ),
                          ],
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final lat = double.tryParse(value);
                              if (lat == null) {
                                return l10n.invalidNumber;
                              }
                              if (lat < -90 || lat > 90) {
                                return l10n.latitudeRange;
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Longitude
                      Expanded(
                        child: TextFormField(
                          controller: _longitudeController,
                          decoration: InputDecoration(
                            labelText: l10n.longitude,
                            hintText: '36.8350',
                            prefixIcon: const Icon(Icons.straighten),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^-?\d*\.?\d*'),
                            ),
                          ],
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final lon = double.tryParse(value);
                              if (lon == null) {
                                return l10n.invalidNumber;
                              }
                              if (lon < -180 || lon > 180) {
                                return l10n.longitudeRange;
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // GPS Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.gpsOptionalInfo,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.cancel),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _handleSave,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(_isEditMode ? l10n.saveChanges : l10n.addFarm),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
