import 'package:flutter/material.dart';
import '../models/faq_item.dart';

class FAQList extends StatefulWidget {
  final List<FAQItem> items;

  const FAQList({super.key, required this.items});

  @override
  State<FAQList> createState() => _FAQListState();
}

class _FAQListState extends State<FAQList> {
  String _selectedCategory = 'All';
  int? _expandedIndex;

  List<String> get _categories {
    final categories = widget.items.map((item) => item.category).toSet().toList();
    categories.insert(0, 'All');
    return categories;
  }

  List<FAQItem> get _filteredItems {
    if (_selectedCategory == 'All') {
      return widget.items;
    }
    return widget.items.where((item) => item.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                      _expandedIndex = null;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1),
        // FAQ list
        Expanded(
          child: _filteredItems.isEmpty
              ? Center(
                  child: Text(
                    'No FAQs found',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : ListView.separated(
                  itemCount: _filteredItems.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    final isExpanded = _expandedIndex == index;
                    return ExpansionTile(
                      key: ValueKey(item.id),
                      title: Text(
                        item.question,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      subtitle: Text(
                        item.category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      initiallyExpanded: isExpanded,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _expandedIndex = expanded ? index : null;
                        });
                      },
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            item.answer,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}
