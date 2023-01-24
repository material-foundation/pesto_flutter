import 'package:flutter/material.dart';

import 'selected_chip.dart';

class FilterList extends StatelessWidget {
  const FilterList({
    super.key,
    required this.allFilters,
    required this.activeFilters,
  });

  final List<String> allFilters, activeFilters;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final filter in allFilters)
            Padding(
              padding: const EdgeInsets.all(4),
              child: activeFilters.contains(filter)
                  ? SelectedChip(
                      label: filter,
                      onTap: () {},
                    )
                  : ChoiceChip(
                      selected: false,
                      label: Text(filter),
                      tooltip: 'Add "$filter" filter',
                      onSelected: (_) {},
                    ),
            )
        ],
      ),
    );
  }
}
