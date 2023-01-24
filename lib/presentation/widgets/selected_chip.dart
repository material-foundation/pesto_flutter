import 'package:flutter/material.dart';

class SelectedChip extends StatelessWidget {
  const SelectedChip({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return RawChip(
        label: Text(label),
        onPressed: onTap,
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: onTap,
        backgroundColor: colors.secondaryContainer,
        deleteIconColor: colors.onSecondaryContainer,
        labelStyle: TextStyle(color: colors.onSecondaryContainer),
        deleteButtonTooltipMessage: 'Remove $label',
        side: BorderSide(color: colors.secondaryContainer));
  }
}
