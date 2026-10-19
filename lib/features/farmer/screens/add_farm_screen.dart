import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/farmer_provider.dart';
import '../../../core/providers/location_provider.dart';
import '../../../core/services/session_service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

/// Add Farm Screen
/// Allows farmer to add a new farm with GPS location
class AddFarmScreen extends StatefulWidget {
  const AddFarmScreen({super.key});

  @override
  State<AddFarmScreen> createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends State<AddFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sessionService = SessionService();
  final _farmNameController = TextEditingController();
  final _hectaresController = TextEditingController();
  final _woredaController = TextEditingController();
  final _kebeleController = TextEditingController();

  double? _latitude;
  double? _longitude;
  bool _isSubmitting = false;
  bool _isGettingLocation = false;

  @override
  void dispose() {
    _farmNameController.dispose();
    _hectaresController.dispose();
    _woredaController.dispose();
    _kebeleController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      final locationProvider = context.read<LocationProvider>();
      await locationProvider.requestPermission();

      if (locationProvider.hasPermission) {
        await locationProvider.getCurrentLocation();
        final location = locationProvider.currentPosition;

        if (location != null) {
          setState(() {
            _latitude = location.latitude;
            _longitude = location.longitude;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Location captured successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Location permission denied'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please capture farm location'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final farmerId = _sessionService.currentUserId;
    if (farmerId == null) return;

    setState(() => _isSubmitting = true);

    final farmData = {
      'farmName': _farmNameController.text.trim(),
      'latitude': _latitude,
      'longitude': _longitude,
      'totalHectares': double.parse(_hectaresController.text.trim()),
      'woreda': _woredaController.text.trim(),
      'kebele': _kebeleController.text.trim(),
    };

    final farm = await context.read<FarmerProvider>().createFarm(
          farmerId: farmerId,
          farmData: farmData,
        );

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (farm != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Farm added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        final error = context.read<FarmerProvider>().error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to add farm'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        title: Text(
          'Add Farm',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _farmNameController,
              decoration: InputDecoration(
                labelText: 'Farm Name',
                hintText: 'Enter farm name',
                prefixIcon: const Icon(Icons.agriculture),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter farm name';
                }
                return null;
              },
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hectaresController,
              decoration: InputDecoration(
                labelText: 'Total Hectares',
                hintText: 'Enter total hectares',
                prefixIcon: const Icon(Icons.crop_landscape),
                suffixText: 'ha',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter total hectares';
                }
                final hectares = double.tryParse(value.trim());
                if (hectares == null || hectares <= 0) {
                  return 'Please enter a valid number greater than 0';
                }
                return null;
              },
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _woredaController,
              decoration: InputDecoration(
                labelText: 'Woreda',
                hintText: 'Enter woreda',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter woreda';
                }
                return null;
              },
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _kebeleController,
              decoration: InputDecoration(
                labelText: 'Kebele',
                hintText: 'Enter kebele',
                prefixIcon: const Icon(Icons.location_city),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter kebele';
                }
                return null;
              },
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.gps_fixed, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Farm Location',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_latitude != null && _longitude != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.success),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: AppColors.success, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Location Captured',
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Lat: ${_latitude!.toStringAsFixed(6)}\n'
                                    'Lon: ${_longitude!.toStringAsFixed(6)}',
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Please capture the farm location using GPS',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: (_isSubmitting || _isGettingLocation)
                            ? null
                            : _getCurrentLocation,
                        icon: _isGettingLocation
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location),
                        label: Text(_isGettingLocation
                            ? 'Getting Location...'
                            : 'Capture Location'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Add Farm',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
