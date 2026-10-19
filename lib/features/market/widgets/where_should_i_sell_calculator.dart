import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/crop_plot_model.dart';
import '../../../core/models/sell_recommendation_model.dart';
import '../../../core/services/recommendation_service.dart';
import 'recommendation_card.dart';

/// Where Should I Sell? Calculator
/// Flagship feature: Net Revenue = (Market Price * Quantity) - Transport Cost - Checkpoint Fees
class WhereShouldISellCalculator extends StatefulWidget {
  const WhereShouldISellCalculator({super.key});

  @override
  State<WhereShouldISellCalculator> createState() =>
      _WhereShouldISellCalculatorState();
}

class _WhereShouldISellCalculatorState
    extends State<WhereShouldISellCalculator> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();

  CropType _selectedCrop = CropType.potato;
  QualityGrade _selectedGrade = QualityGrade.grade1;
  List<SellRecommendation>? _recommendations;
  bool _isCalculating = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCalculating = true;
      _recommendations = null;
    });

    try {
      final quantity = double.parse(_quantityController.text);
      final recommendations =
          await RecommendationService.calculateRecommendations(
        cropType: _selectedCrop,
        grade: _selectedGrade,
        quantityKg: quantity,
      );

      setState(() {
        _recommendations = recommendations;
        _isCalculating = false;
      });
    } catch (e) {
      setState(() => _isCalculating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error calculating: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.primaryVeryLight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        localizations.whereShouldISell,
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Calculate net revenue after transport and checkpoint fees',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Input Form
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.surface,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Crop Selection
                  Text(
                    'Select Crop',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCropDropdown(),

                  const SizedBox(height: 20),

                  // Grade Selection
                  Text(
                    'Select Grade',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildGradeDropdown(),

                  const SizedBox(height: 20),

                  // Quantity Input
                  Text(
                    'Quantity (kg)',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter quantity in kg',
                      suffixText: 'kg',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter quantity';
                      }
                      final quantity = double.tryParse(value);
                      if (quantity == null || quantity <= 0) {
                        return 'Please enter valid quantity';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Calculate Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isCalculating ? null : _calculate,
                      child: _isCalculating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text('Calculate Best Market'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Results
          if (_recommendations != null) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Recommendations',
                    style: AppTypography.headlineSmall,
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_recommendations!.length} markets',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ..._recommendations!.asMap().entries.map((entry) {
              final index = entry.key;
              final rec = entry.value;
              return RecommendationCard(
                recommendation: rec,
                rank: index + 1,
                isBest: index == 0,
              );
            }).toList(),
            const SizedBox(height: 80), // Bottom padding
          ],

          if (_recommendations == null && !_isCalculating)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.calculate_outlined,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Enter your crop details to see where you should sell',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCropDropdown() {
    return DropdownButtonFormField<CropType>(
      value: _selectedCrop,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: CropType.values.take(5).map((crop) {
        return DropdownMenuItem(
          value: crop,
          child: Row(
            children: [
              Text(
                crop.afaanOromoo,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(width: 8),
              Text(
                '(${crop.displayName})',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedCrop = value);
        }
      },
    );
  }

  Widget _buildGradeDropdown() {
    return DropdownButtonFormField<QualityGrade>(
      value: _selectedGrade,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: QualityGrade.values.map((grade) {
        return DropdownMenuItem(
          value: grade,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getGradeColor(grade),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                grade.displayName,
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedGrade = value);
        }
      },
    );
  }

  Color _getGradeColor(QualityGrade grade) {
    switch (grade) {
      case QualityGrade.premium:
        return AppColors.gold;
      case QualityGrade.grade1:
        return AppColors.primary;
      case QualityGrade.grade2:
        return AppColors.info;
      case QualityGrade.grade3:
        return AppColors.warning;
      case QualityGrade.standard:
        return AppColors.textSecondary;
    }
  }
}
