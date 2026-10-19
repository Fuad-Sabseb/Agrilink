import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/colors.dart';
import '../../core/services/session_service.dart';
import '../../core/services/produce_service.dart';
import '../../models/produce_model.dart';
import '../../widgets/produce_card.dart';
import 'edit_produce_screen.dart';

class MyProduceScreen extends StatelessWidget {
  const MyProduceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionService = SessionService();
    final produceService = ProduceService();

    final bool boxesOpen = Hive.isBoxOpen('produce');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Produce'),
      ),
      body: !boxesOpen
          ? _buildEmptyState()
          : ValueListenableBuilder<Box<ProduceModel>>(
              valueListenable: Hive.box<ProduceModel>('produce').listenable(),
              builder: (context, box, _) {
                final userId = sessionService.currentUserId;
                final produceList = box.values.where((p) => p.farmerId == userId).toList()
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (produceList.isEmpty) {
                  return _buildEmptyState();
                }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: produceList.length,
            itemBuilder: (context, index) {
              final produce = produceList[index];
              return ProduceCard(
                produce: produce,
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditProduceScreen(produce: produce)),
                ),
                onDelete: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Produce'),
                      content: Text('Are you sure you want to delete "${produce.cropName}"?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await produceService.deleteProduce(produce.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Produce deleted.')),
                      );
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.disabled),
          const SizedBox(height: 16),
          const Text(
            'No produce listed yet',
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your produce from the Add tab.',
            style: TextStyle(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
