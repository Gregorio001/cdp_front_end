import 'dart:io';
import 'dart:typed_data';

import 'package:cdp_contract_comparison/api/api_service.dart';
import 'package:cdp_contract_comparison/models/analysis_models.dart';
import 'package:flutter/foundation.dart';


class AnalysisProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // --- STATO ---
  bool _isLoading = false;
  List<AnalyzedClause>? _analysisResult;
  String? _errorMessage;
  bool _isChatLoading = false;
  final List<ChatMessage> _chatHistory = [];

  // --- GETTER PUBBLICI ---
  bool get isLoading => _isLoading;
  List<AnalyzedClause>? get analysisResult => _analysisResult;
  String? get errorMessage => _errorMessage;
  bool get isChatLoading => _isChatLoading;
  List<ChatMessage> get chatHistory => List.unmodifiable(_chatHistory);


  // --- AZIONI PRINCIPALI ---

  /// Avvia l'analisi da un file (per mobile/desktop).
  Future<void> performAnalysisFromFile({
    required File file,
    required String standardId,
  }) async {
    // Legge i byte dal file e chiama il metodo generico
    final Uint8List fileBytes = await file.readAsBytes();
    await _analyze(
      fileBytes: fileBytes,
      filename: file.path.split('/').last,
      standardId: standardId,
    );
  }

  /// Avvia l'analisi da bytes (per web).
  Future<void> performAnalysisFromBytes({
    required Uint8List fileBytes,
    required String filename,
    required String standardId,
  }) async {
    await _analyze(
      fileBytes: fileBytes,
      filename: filename,
      standardId: standardId,
    );
  }

  /// Metodo privato che esegue l'analisi.
  Future<void> _analyze({
    required Uint8List fileBytes,
    required String filename,
    required String standardId,
  }) async {
    _isLoading = true;
    _analysisResult = null;
    _errorMessage = null;
    clearChat(); // Pulisce la chat precedente all'inizio di una nuova analisi
    notifyListeners();

    try {
      final result = await _apiService.analyzeDocumentFromBytes(
        fileBytes: fileBytes,
        filename: filename,
        standardId: standardId,
      );
      _analysisResult = result;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- AZIONI CHAT ---

  Future<void> sendChatMessage(String message) async {
    if (message.trim().isEmpty || _analysisResult == null) return;

    _chatHistory.add(ChatMessage(text: message, isUser: true));
    _isChatLoading = true;
    notifyListeners();

    try {
      final answer = await _apiService.getChatResponse(
        question: message,
        context: _analysisResult!,
      );
      _chatHistory.add(ChatMessage(text: answer, isUser: false));
    } catch (e) {
      _chatHistory.add(ChatMessage(
        text: 'Errore: ${e.toString().replaceFirst('Exception: ', '')}',
        isUser: false,
      ));
    } finally {
      _isChatLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _chatHistory.clear();
    notifyListeners();
  }

  // --- AZIONI DI RESET ---

  void clearAnalysis() {
    _analysisResult = null;
    _errorMessage = null;
    _isLoading = false;
    clearChat();
    notifyListeners();
  }
}
