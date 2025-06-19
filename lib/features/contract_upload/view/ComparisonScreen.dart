import 'package:cdp_contract_comparison/core/models/comparison_model.dart';
import 'package:cdp_contract_comparison/core/providers/comparison_notifier.dart' show ComparisonProvider;
import 'package:cdp_contract_comparison/features/contract_upload/widget/textviewer.dart' show TextViewer, TextViewerState;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// se vuoi PDF   import '../widgets/pdf_viewer.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ComparisonProvider(),
      child: const _ComparisonView(),
    );
  }
}

class _ComparisonView extends StatefulWidget {
  const _ComparisonView();

  @override
  State<_ComparisonView> createState() => _ComparisonViewState();
}

class _ComparisonViewState extends State<_ComparisonView> {
  final _viewerKey = GlobalKey<TextViewerState>();

  // mappa diff-index → itemIndex dentro il viewer
  Map<int, int> _diffToItemIdx = {};

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ComparisonProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Confronto Documenti Finanziari')),
      body: Row(
        children: [
          // --- Sidebar ----------
          Expanded(
            flex: 1,
            child: _DiffSidebar(
              differences: state.differences,
              onTap: (idx) {
                _viewerKey.currentState?.scrollToDiff(idx);
              },
            ),
          ),
          // --- Area documento ----
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _FilePickRow(),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: state.modelFile != null &&
                        state.proposalFile != null &&
                        !state.isLoading
                        ? () => context.read<ComparisonProvider>().compare()
                        : null,
                    icon: state.isLoading
                        ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                        CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.compare_arrows),
                    label: const Text('Confronta Documenti'),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: state.proposalPdfUrl != null
                    // Se il backend ti ha restituito un PDF già evidenziato
                    // ? PdfViewerWidget(url: state.proposalPdfUrl!)
                        ? Center(
                        child: Text(
                            'TODO: attiva PdfViewerWidget per URL ${state.proposalPdfUrl!}'))
                        : state.proposalText.isEmpty
                        ? const Center(
                        child: Text(
                            'Carica i documenti e avvia il confronto.'))
                        : TextViewer(
                      key: _viewerKey,
                      fullText: state.proposalText,
                      differences: state.differences,
                      onSpanBuilt: (map) =>
                      _diffToItemIdx = map,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilePickRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<ComparisonProvider>();
    return Row(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.attach_file),
          label:
          Text(state.modelFile?.name ?? 'Modello Base (.docx/.pdf)'),
          onPressed: () => context.read<ComparisonProvider>().pickModel(),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.attach_file),
          label:
          Text(state.proposalFile?.name ?? 'Proposta Cliente (.docx/.pdf)'),
          onPressed: () => context.read<ComparisonProvider>().pickProposal(),
        ),
      ],
    );
  }
}

class _DiffSidebar extends StatelessWidget {
  const _DiffSidebar(
      {required this.differences, required this.onTap, super.key});

  final List<Difference> differences;
  final void Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: differences.isEmpty
          ? const Center(
        child: Text('Nessuna differenza ancora.'),
      )
          : ListView.builder(
        itemCount: differences.length,
        itemBuilder: (_, idx) {
          final d = differences[idx];
          final descr = d.llmAnalysis['description'] ?? '';
          return ListTile(
            tileColor: idx.isEven
                ? Colors.white
                : Colors.grey.shade50,
            title: Text('Deroga ${idx + 1} – ${d.type}'),
            subtitle: Text(descr, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => onTap(idx),
          );
        },
      ),
    );
  }
}
