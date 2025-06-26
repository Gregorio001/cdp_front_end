import 'package:flutter/foundation.dart';

// Enum per lo stato della clausola
enum ClauseStatus {
  unchanged, // Invariata rispetto allo standard
  modified,  // Modificata rispetto allo standard
  deleted,   // Presente nello standard ma rimossa dal documento
  brandnew,  // Presente nel documento ma non nello standard
  error      // Stato non riconosciuto o errore
}

// Enum per la raccomandazione del LLM
enum Recommendation {
  accept,          // Accettare la clausola
  reject,          // Rifiutare la clausola
  counterProposal, // Suggerire una controproposta
  error            // Raccomandazione non riconosciuta
}

class AnalyzedClause {
  final String clauseId;
  final ClauseStatus status;
  final String? companyText;
  final String? standardText;
  final List<HistoricalPrecedent> historicalPrecedents;
  final LlmAnalysis? llmAnalysis;

  AnalyzedClause({
    required this.clauseId,
    required this.status,
    this.companyText,
    this.standardText,
    required this.historicalPrecedents,
    this.llmAnalysis,
  });

  factory AnalyzedClause.fromJson(Map<String, dynamic> json) {
    ClauseStatus parseStatus(String? statusStr) {
      switch (statusStr?.toLowerCase()) {
        case 'unchanged': return ClauseStatus.unchanged;
        case 'modified': return ClauseStatus.modified;
        case 'deleted': return ClauseStatus.deleted;
        case 'new': return ClauseStatus.brandnew;
        default: return ClauseStatus.error;
      }
    }

    return AnalyzedClause(
      clauseId: json['clause_id'] as String? ?? 'ID non disponibile',
      status: parseStatus(json['status'] as String?),
      companyText: json['company_text'] as String?,
      standardText: json['standard_text'] as String?,
      historicalPrecedents: (json['historical_precedents'] as List<dynamic>? ?? [])
          .map((item) => HistoricalPrecedent.fromJson(item as Map<String, dynamic>))
          .toList(),
      llmAnalysis: json['llm_analysis'] != null
          ? LlmAnalysis.fromJson(json['llm_analysis'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clause_id': clauseId,
      'status': status.name, // .name converte l'enum in stringa (es. 'modified')
      'company_text': companyText,
      'standard_text': standardText,
      'historical_precedents': historicalPrecedents.map((hp) => hp.toJson()).toList(),
      'llm_analysis': llmAnalysis?.toJson(),
    };
  }
}

class HistoricalPrecedent {
  final String historicalId;
  final String text;
  final Map<String, dynamic> metadata;
  final double similarityScore;

  HistoricalPrecedent({
    required this.historicalId,
    required this.text,
    required this.metadata,
    required this.similarityScore,
  });

  factory HistoricalPrecedent.fromJson(Map<String, dynamic> json) {
    return HistoricalPrecedent(
      historicalId: json['historical_id'] as String? ?? '',
      text: json['text'] as String? ?? 'Testo non disponibile',
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      similarityScore: (json['similarity_score'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'historical_id': historicalId,
      'text': text,
      'metadata': metadata,
      'similarity_score': similarityScore,
    };
  }
}

class LlmAnalysis {
  final String summary;
  final String riskAssessment;
  final Recommendation recommendation;
  final String suggestedCounterProposal;

  LlmAnalysis({
    required this.summary,
    required this.riskAssessment,
    required this.recommendation,
    required this.suggestedCounterProposal,
  });

  factory LlmAnalysis.fromJson(Map<String, dynamic> json) {
    Recommendation parseRecommendation(String? recStr) {
      switch (recStr?.toUpperCase()) {
        case 'ACCEPT': return Recommendation.accept;
        case 'REJECT': return Recommendation.reject;
        case 'COUNTER-PROPOSAL': return Recommendation.counterProposal;
        default: return Recommendation.error;
      }
    }

    return LlmAnalysis(
      summary: json['summary'] as String? ?? 'N/D',
      riskAssessment: json['risk_assessment'] as String? ?? 'N/D',
      recommendation: parseRecommendation(json['recommendation'] as String?),
      suggestedCounterProposal: json['suggested_counter_proposal'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    String recommendationToString(Recommendation rec) {
      switch (rec) {
        case Recommendation.accept: return 'ACCEPT';
        case Recommendation.reject: return 'REJECT';
        case Recommendation.counterProposal: return 'COUNTER-PROPOSAL';
        case Recommendation.error: return 'ERROR';
      }
    }

    return {
      'summary': summary,
      'risk_assessment': riskAssessment,
      'recommendation': recommendationToString(recommendation),
      'suggested_counter_proposal': suggestedCounterProposal,
    };
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
