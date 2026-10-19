import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/providers/woreda_provider.dart';
import '../../../core/providers/auth_provider.dart';

class WoredaSwitcher extends StatelessWidget {
  final bool showAsDropdown;
  final VoidCallback? onWoredaChanged;

  const WoredaSwitcher({
    super.key,
    this.showAsDropdown = true,
    this.onWoredaChanged,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final woredaProvider = context.watch<WoredaProvider>();

    // Only show for bureau officers with multiple woredas
    if (authProvider.user?.role != 'bureau_officer') {
      return const SizedBox.shrink();
    }

    if (woredaProvider.isLoading && woredaProvider.assignedWoredas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (woredaProvider.error != null && woredaProvider.assignedWoredas.isEmpty) {
      return _buildErrorState(context, woredaProvider);
    }

    final woredas = woredaProvider.assignedWoredas;
    
    if (woredas.isEmpty) {
      return _buildNoWoredaState(context);
    }

    // Single woreda - show as read-only
    if (woredas.length == 1) {
      return _buildSingleWoreda(context, woredas.first);
    }

    // Multiple woredas - show dropdown
    if (showAsDropdown) {
      return _buildDropdown(context, woredaProvider);
    } else {
      return _buildList(context, woredaProvider);
    }
  }

  Widget _buildErrorState(BuildContext context, WoredaProvider provider) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 8),
            Text(
              'Failed to load woredas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              provider.error ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () => provider.retry(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoWoredaState(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 48, color: AppColors.secondary),
            const SizedBox(height: 8),
            Text(
              'No Woredas Assigned',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Please contact your administrator',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleWoreda(BuildContext context, woreda) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: ListTile(
        leading: const Icon(Icons.location_on),
        title: Text(woreda.name),
        subtitle: Text('Zone: ${woreda.zone}'),
        trailing: const Icon(Icons.check_circle, color: AppColors.success),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, WoredaProvider provider) {
    final selectedWoreda = provider.selectedWoreda;
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Woreda',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedWoreda?.id,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: provider.assignedWoredas.map((woreda) {
                return DropdownMenuItem(
                  value: woreda.id,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        woreda.name,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Zone: ${woreda.zone}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: provider.isLoading
                  ? null
                  : (woredaId) async {
                      if (woredaId != null && woredaId != selectedWoreda?.id) {
                        final success = await provider.switchWoreda(woredaId);
                        if (success && onWoredaChanged != null) {
                          onWoredaChanged!();
                        }
                      }
                    },
            ),
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(),
              ),
            if (provider.error != null && selectedWoreda != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  provider.error!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, WoredaProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.assignedWoredas.length,
      itemBuilder: (context, index) {
        final woreda = provider.assignedWoredas[index];
        final isSelected = provider.selectedWoreda?.id == woreda.id;

        return ListTile(
          leading: const Icon(Icons.location_on),
          title: Text(woreda.name),
          subtitle: Text('Zone: ${woreda.zone}'),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: AppColors.success)
              : null,
          selected: isSelected,
          onTap: provider.isLoading
              ? null
              : () async {
                  if (!isSelected) {
                    final success = await provider.switchWoreda(woreda.id);
                    if (success && onWoredaChanged != null) {
                      onWoredaChanged!();
                    }
                  }
                },
        );
      },
    );
  }
}
