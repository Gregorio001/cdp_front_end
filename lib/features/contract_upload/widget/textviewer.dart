import 'package:cdp_contract_comparison/core/models/comparison_model.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
class TextViewer extends StatefulWidget {
  const TextViewer(
      {super.key,
        required this.fullText,
        required this.differences,
        required this.onSpanBuilt});

  final String fullText;
  final List<Difference> differences;
  final void Function(Map<int, int>) onSpanBuilt; // diff-index → runePos

  @override
  State<TextViewer> createState() => TextViewerState();
}

class TextViewerState extends State<TextViewer> {
  final ItemScrollController _scrollCtrl = ItemScrollController();

  // mappa diffIndex → indice Item (parola) per scroll
  final Map<int, int> _itemIndexOfDiff = {};

  @override
  void didUpdateWidget(TextViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fullText != widget.fullText) {
      _itemIndexOfDiff.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSpanBuilt(_itemIndexOfDiff);
    });
  }

  @override
  Widget build(BuildContext context) {
    // split by word to be able to scroll precisely
    final words = widget.fullText.split(RegExp(r'(\s+)'));
    // costruiamo un set di posizioni di highlight
    final Map<int, Difference> highlightLookup = {};
    for (var i = 0; i < widget.differences.length; i++) {
      final d = widget.differences[i];
      for (var j = d.start; j < d.end; j++) {
        highlightLookup[j] = d;
      }
    }

    return ScrollablePositionedList.builder(
      itemScrollController: _scrollCtrl,
      itemCount: words.length,
      itemBuilder: (_, idx) {
        final d = highlightLookup[idx];
        final highlight = d != null;
        // registra il primo idx di questo diff
        if (highlight && !_itemIndexOfDiff.containsKey(widget.differences.indexOf(d))) {
          _itemIndexOfDiff[widget.differences.indexOf(d)] = idx;
        }
        return Text.rich(TextSpan(
          text: words[idx],
          style: highlight
              ? const TextStyle(
              backgroundColor: Colors.yellow, fontWeight: FontWeight.bold)
              : null,
        ));
      },
    );
  }

  Future<void> scrollToDiff(int diffIdx) async {
    final itemIdx = _itemIndexOfDiff[diffIdx];
    if (itemIdx != null) {
      await _scrollCtrl.scrollTo(
          index: itemIdx,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
    }
  }
}
