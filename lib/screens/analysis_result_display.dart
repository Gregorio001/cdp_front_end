import 'package:cdp_contract_comparison/models/analysis_models.dart';
import 'package:cdp_contract_comparison/widget/clause_card.dart';
import 'package:flutter/material.dart';


class AnalysisResultDisplay extends StatelessWidget {
  final List<AnalyzedClause> result;

  const AnalysisResultDisplay({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dettaglio Analisi Clausole',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text('${result.length} clausole analizzate.'),
        const SizedBox(height: 24),
        ListView.separated(
          itemCount: result.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final clause = result[index];
            // La ClauseCard ora accetta l'intero oggetto e gestisce lo stato internamente
            return ClauseCard(clause: clause);
          },
        ),
      ],
    );
  }
}
