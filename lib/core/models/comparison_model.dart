import 'dart:convert';

class Difference {
  final String type;
  final int start;
  final int end;
  final String proposalSnippet;
  final Map<String, dynamic> llmAnalysis;
  final int? pageNumber;                 // se PDF
  final List<List<double>>? boundingBoxes;

  Difference({
    required this.type,
    required this.start,
    required this.end,
    required this.proposalSnippet,
    required this.llmAnalysis,
    this.pageNumber,
    this.boundingBoxes,
  });

  factory Difference.fromJson(Map<String, dynamic> json) => Difference(
    type: json['type'],
    start: json['proposal_start_index'],
    end: json['proposal_end_index'],
    proposalSnippet: json['proposal_text_snippet'],
    llmAnalysis: (json['llm_analysis'] is String)
        ? Map<String, dynamic>.from(
        jsonDecode(json['llm_analysis'] as String))
        : Map<String, dynamic>.from(json['llm_analysis'] ?? {}),
    pageNumber: json['page_number'],
    boundingBoxes: (json['bounding_boxes'] as List?)
        ?.map<List<double>>((e) => List<double>.from(e))
        .toList(),
  );
}
