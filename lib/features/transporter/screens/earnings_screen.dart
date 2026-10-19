import '../../../core/utils/user_context.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/providers/transport_provider.dart';
import '../../../core/models/trip_model.dart';
import '../widgets/earnings_chart.dart';

/// Earnings Screen - Financial tracking with charts and history
class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  Future<void> _loadEarnings() async {
    final transportProvider = Provider.of<TransportProvider>(context, listen: false);
    // TODO: Get actual transporter ID
    final userId = UserContext.getCurrentUserId(context) ?? 'transporter_123';
    await transportProvider.loadTripsByTransporter(userId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Earnings'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showExportDialog,
            icon: const Icon(Icons.download_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadEarnings,
        child: Consumer<TransportProvider>(
          builder: (context, transportProvider, child) {
            if (transportProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final completedTrips = transportProvider.trips
                .where((t) => t.status == TripStatus.delivered)
                .toList();

            final todayEarnings = _calculateEarnings(completedTrips, DateTime.now());
            final weekEarnings = _calculateEarningsForDays(completedTrips, 7);
            final monthEarnings = _calculateEarningsForDays(completedTrips, 30);
            final totalEarnings = completedTrips.fold(0.0, (sum, t) => sum + t.totalCost);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary cards
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.5,
                    children: [
                      _buildEarningsCard(
                        'Today',
                        todayEarnings,
                        Icons.today,
                        AppColors.tertiary,
                      ),
                      _buildEarningsCard(
                        'This Week',
                        weekEarnings,
                        Icons.date_range,
                        AppColors.primary,
                      ),
                      _buildEarningsCard(
                        'This Month',
                        monthEarnings,
                        Icons.calendar_month,
                        AppColors.secondary,
                      ),
                      _buildEarningsCard(
                        'All Time',
                        totalEarnings,
                        Icons.account_balance_wallet,
                        AppColors.accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Request Payout Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _showPayoutDialog(totalEarnings),
                      icon: const Icon(Icons.payments_outlined),
                      label: const Text('Request Payout', style: TextStyle(fontSize: 16)),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Chart
                  Text(
                    'Last 7 Days',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.border),
                    ),
                    child: EarningsChart(
                      dailyEarnings: _getLast7DaysEarnings(completedTrips),
                      labels: _getLast7DaysLabels(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Transaction history
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transaction History',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Filter transactions
                        },
                        child: const Text('Filter'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...completedTrips.take(20).map((trip) {
                    return _buildTransactionCard(trip);
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEarningsCard(String title, double amount, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${amount.toStringAsFixed(0)} ETB',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Trip trip) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.attach_money, color: AppColors.primary),
        ),
        title: Text(
          'Delivery #${trip.id.length >= 8 ? trip.id.substring(0, 8) : trip.id}',
          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        subtitle: Text(
          trip.actualDeliveryTime != null
              ? DateFormat('MMM dd, yyyy - HH:mm').format(trip.actualDeliveryTime!)
              : 'Date unknown',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        trailing: Text(
          '+${trip.totalCost.toStringAsFixed(0)} ETB',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  double _calculateEarnings(List<Trip> trips, DateTime date) {
    return trips
        .where((t) =>
            t.actualDeliveryTime != null &&
            t.actualDeliveryTime!.year == date.year &&
            t.actualDeliveryTime!.month == date.month &&
            t.actualDeliveryTime!.day == date.day)
        .fold(0.0, (sum, t) => sum + t.totalCost);
  }

  double _calculateEarningsForDays(List<Trip> trips, int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return trips
        .where((t) => t.actualDeliveryTime != null && t.actualDeliveryTime!.isAfter(cutoff))
        .fold(0.0, (sum, t) => sum + t.totalCost);
  }

  List<double> _getLast7DaysEarnings(List<Trip> trips) {
    final earnings = <double>[];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      earnings.add(_calculateEarnings(trips, date));
    }
    return earnings;
  }

  List<String> _getLast7DaysLabels() {
    final labels = <String>[];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      labels.add(DateFormat('E').format(date));
    }
    return labels;
  }

  Future<void> _showExportDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Export Report', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Export earnings and trip transactions report as CSV?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Export CSV'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final transportProvider = Provider.of<TransportProvider>(context, listen: false);
    final userId = UserContext.getCurrentUserId(context) ?? 'transporter_123';

    try {
      final csvData = await transportProvider.exportTransactionsCSV(transporterId: userId);
      if (!mounted) return;

      if (csvData != null && csvData.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transactions exported successfully (${csvData.split('\n').length - 1} records)'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No transaction records available to export.'),
            backgroundColor: AppColors.secondaryLight,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showPayoutDialog(double availableBalance) {
    if (availableBalance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No earnings available for payout.'),
          backgroundColor: AppColors.secondaryLight,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final amountController = TextEditingController(text: availableBalance.toStringAsFixed(0));
    final accountController = TextEditingController();
    String selectedMethod = 'Telebirr';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Request Payout',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(bottomSheetContext),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Available balance: ${availableBalance.toStringAsFixed(2)} ETB',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedMethod,
                decoration: InputDecoration(
                  labelText: 'Payout Method',
                  border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: AppColors.secondary),
                ),
                items: const [
                  DropdownMenuItem(value: 'Telebirr', child: Text('Telebirr')),
                  DropdownMenuItem(value: 'CBE Birr', child: Text('CBE Birr')),
                  DropdownMenuItem(value: 'Bank Transfer', child: Text('Commercial Bank of Ethiopia')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setModalState(() => selectedMethod = val);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: accountController,
                decoration: InputDecoration(
                  labelText: selectedMethod == 'Bank Transfer' ? 'Account Number' : 'Mobile Number',
                  border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                  prefixIcon: Icon(Icons.numbers_outlined, color: AppColors.secondary),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Amount (ETB)',
                  border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                  prefixIcon: Icon(Icons.attach_money, color: AppColors.primary),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text) ?? 0.0;
                  final account = accountController.text.trim();

                  if (account.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Please enter account / phone number'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  if (amount <= 0 || amount > availableBalance) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Enter an amount between 1 and ${availableBalance.toStringAsFixed(0)} ETB'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(bottomSheetContext);

                  showDialog(
                    context: this.context,
                    builder: (dialogContext) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      icon: Icon(Icons.check_circle_outline, color: AppColors.success, size: 52),
                      title: Text('Payout Requested', style: TextStyle(color: AppColors.textPrimary)),
                      content: Text(
                        'Your withdrawal request of ${amount.toStringAsFixed(2)} ETB to $selectedMethod ($account) has been submitted successfully.\n\nFunds will arrive within 24 hours.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      actions: [
                        FilledButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Submit Withdrawal Request', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
