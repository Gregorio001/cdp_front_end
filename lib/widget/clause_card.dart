import 'package:cdp_contract_comparison/models/analysis_models.dart';
import 'package:cdp_contract_comparison/theme/app_theme.dart';
import 'package:flutter/material.dart';


class ClauseCard extends StatelessWidget {
  final AnalyzedClause clause;

  const ClauseCard({super.key, required this.clause});

  // Helper per ottenere dati stilistici in base allo stato
  ({Color bgColor, Color borderColor, IconData icon}) _getStyleFromStatus() {
    switch (clause.status) {
      case ClauseStatus.unchanged:
        return (bgColor: AppTheme.greenLightColor.withOpacity(0.4), borderColor: AppTheme.greenColor, icon: Icons.check_circle_outline);
      case ClauseStatus.modified:
        return (bgColor: AppTheme.yellowLightColor, borderColor: AppTheme.yellowColor, icon: Icons.edit_outlined);
      case ClauseStatus.deleted:
        return (bgColor: AppTheme.redLightColor, borderColor: AppTheme.redColor, icon: Icons.remove_circle_outline);
      case ClauseStatus.brandnew:
        return (bgColor: AppTheme.blueLightColor, borderColor: AppTheme.blueColor, icon: Icons.add_circle_outline);
      case ClauseStatus.error:
        return (bgColor: AppTheme.borderColor, borderColor: AppTheme.textSecondaryColor, icon: Icons.error_outline);
    }
  }

  String _getStatusText() {
    switch (clause.status) {
      case ClauseStatus.unchanged: return 'INVARIATA';
      case ClauseStatus.modified: return 'MODIFICATA';
      case ClauseStatus.deleted: return 'RIMOSSA';
      case ClauseStatus.brandnew: return 'NUOVA';
      case ClauseStatus.error: return 'ERRORE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _getStyleFromStatus();
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
              color: style.bgColor.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(-5, 0))
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barra laterale colorata
            Container(
              width: 12,
              decoration: BoxDecoration(
                color: style.borderColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11),
                  bottomLeft: Radius.circular(11),
                ),
              ),
              child: Center(
                  child: Icon(style.icon, color: Colors.white, size: 18)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, style),
                    const SizedBox(height: 12),
                    _buildClauseText(context),
                    if (clause.llmAnalysis != null) ...[
                      const Divider(height: 32, thickness: 1),
                      _buildLlmAnalysis(context),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ({Color borderColor, Color bgColor, IconData icon}) style) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            'Clausola ID: ${clause.clauseId}',
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: style.bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: style.borderColor.withOpacity(0.5)),
          ),
          child: Text(
            _getStatusText(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: style.borderColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClauseText(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // A seconda dello stato, mostra testi diversi
    switch (clause.status) {
      case ClauseStatus.modified:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(clause.standardText != null) ...[
              Text("Testo Standard:", style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text(
                clause.standardText!,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondaryColor,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if(clause.companyText != null) ... [
              Text("Testo Modificato:", style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text(clause.companyText!, style: textTheme.bodyLarge),
            ]
          ],
        );
      case ClauseStatus.deleted:
        return Text(
          clause.standardText ?? 'Testo standard non disponibile.',
          style: textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondaryColor),
        );
      case ClauseStatus.brandnew:
      case ClauseStatus.unchanged:
      default:
        return Text(
          clause.companyText ?? 'Testo non disponibile.',
          style: textTheme.bodyLarge,
        );
    }
  }

  Widget _buildLlmAnalysis(BuildContext context) {
    final analysis = clause.llmAnalysis!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Analisi AI", style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildInfoRow(Icons.short_text, "Riepilogo:", analysis.summary, context),
        const SizedBox(height: 4),
        _buildInfoRow(Icons.security, "Rischio:", analysis.riskAssessment, context),
        const SizedBox(height: 4),
        _buildInfoRow(Icons.recommend_outlined, "Azione Consigliata:", analysis.recommendation.name.toUpperCase(), context),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondaryColor),
        const SizedBox(width: 8),
        Text("$label ", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}
