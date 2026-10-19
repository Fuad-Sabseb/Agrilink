import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/farmer_model.dart';
import '../../../core/models/farm_model.dart';
import '../../../core/models/crop_plot_model.dart';
import '../widgets/farm_card.dart';
import '../widgets/add_farm_dialog.dart';
import 'settings_screen.dart';

/// Profile Screen
/// Module 1: Farmer & Farm Registry
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Mock current farmer (in real app, from auth/state management)
  late Farmer _currentFarmer;
  final List<Farm> _farms = [];

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    // Mock farmer profile
    _currentFarmer = Farmer(
      id: 'farmer_001',
      name: 'Abdullahi Mohammed',
      phoneNumber: '+251912345678',
      woreda: 'Jimma Town',
      kebele: 'Kebele 07',
      cooperativeName: 'Jimma Coffee Cooperative',
      registeredAt: DateTime.now().subtract(const Duration(days: 180)),
    );

    // Mock farms
    _farms.addAll([
      Farm(
        id: 'farm_001',
        farmerId: _currentFarmer.id,
        farmName: 'Main Coffee Plot',
        latitude: 7.6731,
        longitude: 36.8355,
        totalHectares: 2.5,
        woreda: 'Jimma Town',
        kebele: 'Kebele 07',
        cropPlots: [
          CropPlot(
            id: 'plot_001',
            cropType: CropType.coffee,
            hectares: 2.0,
            expectedGrade: QualityGrade.grade1,
            expectedYieldPerHectare: 700,
            plantingDate: DateTime(2023, 3, 15),
            expectedHarvestDate: DateTime(2025, 11, 30),
            notes: 'Arabica variety, well-maintained',
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
      ),
      Farm(
        id: 'farm_002',
        farmerId: _currentFarmer.id,
        farmName: 'Maize Field',
        latitude: 7.6800,
        longitude: 36.8400,
        totalHectares: 1.5,
        woreda: 'Jimma Town',
        kebele: 'Kebele 07',
        cropPlots: [
          CropPlot(
            id: 'plot_002',
            cropType: CropType.maize,
            hectares: 1.5,
            expectedGrade: QualityGrade.grade1,
            expectedYieldPerHectare: 4500,
            plantingDate: DateTime(2024, 6, 10),
            expectedHarvestDate: DateTime(2025, 2, 15),
            notes: 'Improved seed variety',
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(localizations.profile),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Farmer Profile Card
            _buildFarmerProfileCard(),

            const SizedBox(height: 24),

            // My Farms Section
            _buildMyFarmsSection(localizations),

            const SizedBox(height: 80), // Bottom padding
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFarmDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Farm'),
      ),
    );
  }

  Widget _buildFarmerProfileCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentFarmer.name,
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _currentFarmer.phoneNumber,
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          _buildProfileInfoRow(
            Icons.location_on,
            'Location',
            '${_currentFarmer.woreda}, ${_currentFarmer.kebele}',
          ),
          const SizedBox(height: 12),
          _buildProfileInfoRow(
            Icons.groups,
            'Cooperative',
            _currentFarmer.cooperativeName ?? 'None',
          ),
          const SizedBox(height: 12),
          _buildProfileInfoRow(
            Icons.calendar_today,
            'Member since',
            _formatDate(_currentFarmer.registeredAt),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white70,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyFarmsSection(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'My Farms',
                style: AppTypography.headlineSmall,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_farms.length} farms',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_farms.isEmpty)
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(
                  Icons.agriculture_outlined,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No farms registered yet',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap + to add your first farm',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ..._farms.map((farm) => FarmCard(farm: farm)),
      ],
    );
  }

  void _showAddFarmDialog() async {
    final farm = await showDialog<Farm>(
      context: context,
      builder: (context) => const AddFarmDialog(),
    );
    
    if (farm != null) {
      setState(() => _farms.add(farm));
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
