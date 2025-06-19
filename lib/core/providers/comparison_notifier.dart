import 'package:cdp_contract_comparison/core/models/comparison_model.dart';
import 'package:cdp_contract_comparison/core/services/ApiService.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';


class ComparisonProvider extends ChangeNotifier {
  final _api = const ApiService();

  PlatformFile? modelFile;
  PlatformFile? proposalFile;

  String proposalText = '';
  String? proposalPdfUrl;
  List<Difference> differences = [];
  bool isLoading = false;

  Future<void> pickModel() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx', 'pdf'],
    );
    if (res != null) {
      modelFile = res.files.first;
      notifyListeners();
    }
  }

  Future<void> pickProposal() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx', 'pdf'],
    );
    if (res != null) {
      proposalFile = res.files.first;
      notifyListeners();
    }
  }

  Future<void> compare() async {
    if (modelFile == null || proposalFile == null) return;
    isLoading = true;
    notifyListeners();

    try {
      final (fullText, diffs, pdfUrl) =
      await _api.compareDocuments(modelFile!, proposalFile!);
      proposalText = fullText;
      proposalPdfUrl = pdfUrl;
      differences = diffs;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
