// CORREZIONE: Ho sostituito 'AppTheme.colors.green500' con 'AppTheme.greenColor', etc.
// per allinearlo alla struttura di AppTheme che abbiamo definito.

import 'package:cdp_contract_comparison/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';


enum DiffType { added, removed, modified }

class DiffCard extends StatelessWidget {
  final DiffType type;
  final String title;
  final String message;
  const DiffCard({
    super.key,
    required this.type,
    required this.title,
    required this.message,
  });

  Color _border() {
    switch (type) {
      case DiffType.added:
        return AppTheme.greenColor;
      case DiffType.removed:
        return AppTheme.redColor;
      case DiffType.modified:
      default:
        return AppTheme.blueColor;
    }
  }

  Color _bg() {
    switch (type) {
      case DiffType.added:
        return AppTheme.greenLightColor;
      case DiffType.removed:
        return AppTheme.redLightColor;
      case DiffType.modified:
      default:
        return AppTheme.blueLightColor;
    }
  }

  Color _iconColor() {
    switch (type) {
      case DiffType.added:
        return AppTheme.greenColor;
      case DiffType.removed:
        return AppTheme.redColor;
      case DiffType.modified:
      default:
        return AppTheme.blueColor;
    }
  }

  IconData _icon() {
    switch (type) {
      case DiffType.added:
        return Symbols.add;
      case DiffType.removed:
        return Symbols.remove;
      case DiffType.modified:
      default:
        return Symbols.edit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bg(),
        border: Border(left: BorderSide(color: _border(), width: 4)),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(_icon(), color: _iconColor(), size: 18),
            const SizedBox(width: 4),
            Text(title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _iconColor(),
                )),
          ]),
          const SizedBox(height: 4),
          Text(message,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: _iconColor())),
        ],
      ),
    );
  }
}
