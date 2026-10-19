import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

/// Earnings Chart - Simple bar chart for earnings visualization
class EarningsChart extends StatelessWidget {
  final List<double> dailyEarnings;
  final List<String> labels;

  const EarningsChart({
    super.key,
    required this.dailyEarnings,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final maxEarning = dailyEarnings.isEmpty
        ? 1.0
        : dailyEarnings.reduce((a, b) => a > b ? a : b);
    final safeMax = maxEarning > 0 ? maxEarning : 1.0;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(dailyEarnings.length, (index) {
          final earning = dailyEarnings[index];
          final height = (earning / safeMax) * 110;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Earnings value
                  if (earning > 0)
                    Text(
                      '${earning.toInt()}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  const SizedBox(height: 4),

                  // Bar
                  Container(
                    width: double.infinity,
                    height: height.clamp(4, 110),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.6),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Label
                  Text(
                    labels[index],
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
