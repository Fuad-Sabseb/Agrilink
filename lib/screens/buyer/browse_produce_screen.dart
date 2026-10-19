import 'package:flutter/material.dart';
import '../../core/services/produce_service.dart';
import '../../models/produce_model.dart';
import '../../widgets/produce_card.dart';
import '../../features/buyer/screens/produce_details_screen.dart';

class BrowseProduceScreen extends StatefulWidget {
  const BrowseProduceScreen({super.key});

  @override
  State<BrowseProduceScreen> createState() => _BrowseProduceScreenState();
}

class _BrowseProduceScreenState extends State<BrowseProduceScreen> {
  final _produceService = ProduceService();

  List<ProduceModel> _availableProduce = [];

  @override
  void initState() {
    super.initState();
    _loadProduce();
  }

  void _loadProduce() {
    setState(() {
      _availableProduce = _produceService.getAllAvailableProduce();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Browse Produce')),
      body: _availableProduce.isEmpty
          ? const Center(child: Text('No produce available right now.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _availableProduce.length,
              itemBuilder: (context, index) {
                final produce = _availableProduce[index];
                return ProduceCard(
                  produce: produce,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProduceDetailsScreen(produce: produce),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
