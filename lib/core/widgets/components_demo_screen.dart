import 'package:flutter/material.dart';
import 'agri_button.dart';
import 'agri_text_field.dart';
import 'agri_dropdown.dart';
import 'dashboard_card.dart';
import 'action_card.dart';
import 'statistic_card.dart';
import 'role_badge.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';

/// Components Demo Screen
/// 
/// A comprehensive demonstration screen showing all AgriLink UI components
/// in action. This serves as a visual reference and testing ground for
/// the Agricultural Earth-Tone design system components.
/// 
/// Components demonstrated:
/// - AgriButton (primary, secondary, text variants)
/// - DashboardCard (simple, with subtitle, interactive)
/// - ActionCard (standard and highlighted)
/// - StatisticCard (with and without trends)
/// - AgriTextField (various input types)
/// - AgriDropdown (selection lists)
/// - RoleBadge (all role types)
/// 
/// This screen can be used for:
/// - Design review and approval
/// - Component testing and QA
/// - Developer reference for implementation
/// - Stakeholder demonstrations
class ComponentsDemoScreen extends StatefulWidget {
  const ComponentsDemoScreen({super.key});

  @override
  State<ComponentsDemoScreen> createState() => _ComponentsDemoScreenState();
}

class _ComponentsDemoScreenState extends State<ComponentsDemoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedCrop;
  bool _isLoading = false;

  final List<DropdownMenuItem<String>> _cropItems = const [
    DropdownMenuItem(value: 'maize', child: Text('Maize')),
    DropdownMenuItem(value: 'wheat', child: Text('Wheat')),
    DropdownMenuItem(value: 'teff', child: Text('Teff')),
    DropdownMenuItem(value: 'coffee', child: Text('Coffee')),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleButtonPress() {
    setState(() {
      _isLoading = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Action completed!')),
        );
      }
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriLink Components Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About'),
                  content: const Text(
                    'This screen demonstrates all AgriLink UI components '
                    'following the Agricultural Earth-Tone design system.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Header
            Container(
              padding: const EdgeInsets.all(AppTokens.spaceL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTokens.radiusM),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AgriLink Design System',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTokens.spaceXS),
                  Text(
                    'Agricultural Earth-Tone Components',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.spaceXL),

            // Section 1: Role Badges
            _buildSectionHeader('Role Badges'),
            const SizedBox(height: AppTokens.spaceM),
            const Wrap(
              spacing: AppTokens.spaceM,
              runSpacing: AppTokens.spaceM,
              children: [
                RoleBadge(role: 'farmer'),
                RoleBadge(role: 'buyer'),
                RoleBadge(role: 'transporter'),
                RoleBadge(role: 'bureau'),
              ],
            ),
            const SizedBox(height: AppTokens.spaceXL),

            // Section 2: Buttons
            _buildSectionHeader('Buttons'),
            const SizedBox(height: AppTokens.spaceM),
            AgriButton.primary(
              text: 'Primary Button',
              icon: Icons.check,
              onPressed: () => _showSnackbar('Primary button pressed'),
            ),
            const SizedBox(height: AppTokens.spaceS),
            AgriButton.secondary(
              text: 'Secondary Button',
              icon: Icons.edit,
              onPressed: () => _showSnackbar('Secondary button pressed'),
            ),
            const SizedBox(height: AppTokens.spaceS),
            AgriButton.text(
              text: 'Text Button',
              icon: Icons.info_outline,
              onPressed: () => _showSnackbar('Text button pressed'),
            ),
            const SizedBox(height: AppTokens.spaceS),
            AgriButton.primary(
              text: 'Loading Button',
              isLoading: _isLoading,
              onPressed: _handleButtonPress,
            ),
            const SizedBox(height: AppTokens.spaceS),
            const AgriButton.primary(
              text: 'Disabled Button',
              onPressed: null,
            ),
            const SizedBox(height: AppTokens.spaceXL),

            // Section 3: Statistics Cards
            _buildSectionHeader('Statistics Cards'),
            const SizedBox(height: AppTokens.spaceM),
            Row(
              children: const [
                Expanded(
                  child: StatisticCard(
                    label: 'Total Farms',
                    value: '12',
                    icon: Icons.agriculture_outlined,
                    color: AppColors.roleFarmer,
                    trend: '+3',
                    trendPositive: true,
                  ),
                ),
                SizedBox(width: AppTokens.spaceM),
                Expanded(
                  child: StatisticCard(
                    label: 'Revenue',
                    value: '25K ETB',
                    icon: Icons.attach_money,
                    color: AppColors.success,
                    trend: '+12%',
                    trendPositive: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spaceM),
            Row(
              children: const [
                Expanded(
                  child: StatisticCard(
                    label: 'Active Orders',
                    value: '8',
                    icon: Icons.shopping_cart_outlined,
                    color: AppColors.warning,
                  ),
                ),
                SizedBox(width: AppTokens.spaceM),
                Expanded(
                  child: StatisticCard(
                    label: 'Deliveries',
                    value: '47',
                    icon: Icons.local_shipping_outlined,
                    color: AppColors.tertiaryDark,
                    trend: '+5',
                    trendPositive: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spaceXL),

            // Section 4: Action Cards
            _buildSectionHeader('Action Cards'),
            const SizedBox(height: AppTokens.spaceM),
            ActionCard(
              title: 'Where Should I Sell?',
              description: 'Compare market prices to maximize your profit',
              icon: Icons.analytics_outlined,
              primaryColor: AppColors.primary,
              isHighlight: true,
              onTap: () => _showSnackbar('Market intelligence opened'),
            ),
            const SizedBox(height: AppTokens.spaceM),
            ActionCard(
              title: 'Add New Produce',
              description: 'List your crops for sale in the marketplace',
              icon: Icons.add_circle_outline,
              primaryColor: AppColors.success,
              onTap: () => _showSnackbar('Add produce screen opened'),
            ),
            const SizedBox(height: AppTokens.spaceM),
            ActionCard(
              title: 'View My Farms',
              description: 'Manage your registered farms',
              icon: Icons.agriculture_outlined,
              primaryColor: AppColors.roleFarmer,
              onTap: () => _showSnackbar('Farms screen opened'),
            ),
            const SizedBox(height: AppTokens.spaceXL),

            // Section 5: Dashboard Cards
            _buildSectionHeader('Dashboard Cards'),
            const SizedBox(height: AppTokens.spaceM),
            const DashboardCard(
              title: 'Active Listings',
              icon: Icons.list_alt_outlined,
              iconColor: AppColors.primary,
            ),
            const SizedBox(height: AppTokens.spaceM),
            const DashboardCard(
              title: 'Pending Orders',
              subtitle: '5 orders awaiting confirmation',
              icon: Icons.hourglass_empty,
              iconColor: AppColors.warning,
            ),
            const SizedBox(height: AppTokens.spaceM),
            DashboardCard(
              title: 'Market Prices',
              subtitle: 'View current commodity rates',
              icon: Icons.trending_up,
              iconColor: AppColors.tertiary,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showSnackbar('Market prices opened'),
            ),
            const SizedBox(height: AppTokens.spaceXL),

            // Section 6: Form Components
            _buildSectionHeader('Form Components'),
            const SizedBox(height: AppTokens.spaceM),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AgriTextField(
                    label: 'Farm Name',
                    hint: 'Enter your farm name',
                    controller: _nameController,
                    prefix: const Icon(Icons.agriculture_outlined),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Farm name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTokens.spaceM),
                  AgriTextField(
                    label: 'Price (ETB)',
                    hint: '0.00',
                    keyboardType: TextInputType.number,
                    prefix: const Text(
                      'ETB  ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: AppTokens.spaceM),
                  AgriDropdown<String>(
                    label: 'Select Crop Type',
                    hint: 'Choose your crop',
                    value: _selectedCrop,
                    items: _cropItems,
                    onChanged: (value) {
                      setState(() {
                        _selectedCrop = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a crop type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTokens.spaceM),
                  const AgriTextField(
                    label: 'Description',
                    hint: 'Describe your produce',
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppTokens.spaceL),
                  AgriButton.primary(
                    text: 'Validate Form',
                    icon: Icons.check_circle_outline,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _showSnackbar('Form is valid!');
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.spaceXL),

            // Section 7: Color Palette
            _buildSectionHeader('Color Palette'),
            const SizedBox(height: AppTokens.spaceM),
            Wrap(
              spacing: AppTokens.spaceM,
              runSpacing: AppTokens.spaceM,
              children: [
                _buildColorSwatch('Primary', AppColors.primary),
                _buildColorSwatch('Secondary', AppColors.secondary),
                _buildColorSwatch('Tertiary', AppColors.tertiary),
                _buildColorSwatch('Accent', AppColors.accent),
                _buildColorSwatch('Success', AppColors.success),
                _buildColorSwatch('Warning', AppColors.warning),
                _buildColorSwatch('Error', AppColors.error),
                _buildColorSwatch('Farmer', AppColors.roleFarmer),
                _buildColorSwatch('Buyer', AppColors.roleBuyer),
                _buildColorSwatch('Transporter', AppColors.roleTransporter),
                _buildColorSwatch('Bureau', AppColors.roleBureau),
              ],
            ),
            const SizedBox(height: AppTokens.spaceXL),

            // Footer
            Container(
              padding: const EdgeInsets.all(AppTokens.spaceM),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTokens.radiusM),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.agriculture_outlined,
                    size: 40,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppTokens.spaceS),
                  const Text(
                    'AgriLink',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTokens.spaceXXS),
                  Text(
                    'Agricultural Earth-Tone Design System',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTokens.spaceS),
                  const Text(
                    'Requirements 1.10, 1.11, 1.12',
                    style: TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.spaceL),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.only(bottom: AppTokens.spaceXS),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildColorSwatch(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppTokens.radiusS),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(height: AppTokens.spaceXXS),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
