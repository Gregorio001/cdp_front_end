import 'dart:convert';
import 'package:cdp_contract_comparison/core/models/comparison_model.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';


class ApiService {
  const ApiService();

  static const _baseUrlDebugIosWeb = 'http://localhost:7071/api';
  static const _baseUrlDebugAndroid = 'http://10.0.2.2:7071/api';
  static const _baseUrlProd = 'https://YOUR_FUNCTION_APP.azurewebsites.net/api';

  String get _baseUrl {
    const bool kDebug = bool.fromEnvironment('dart.vm.product') == false;
    // Semplificazione: decidi tu quale usare
    return kDebug ? _baseUrlDebugIosWeb : _baseUrlProd;
  }

  Future<(String fullText, List<Difference> diffs, String? pdfUrl)>
  compareDocuments(PlatformFile model, PlatformFile proposal) async {
    final uri = Uri.parse('$_baseUrl/compare_documents');
    final req = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes(
          'model_document', model.bytes!,
          filename: model.name))
      ..files.add(http.MultipartFile.fromBytes(
          'proposal_document', proposal.bytes!,
          filename: proposal.name));

    final res = await http.Response.fromStream(await req.send());
    if (res.statusCode != 200) {
      throw Exception('Errore ${res.statusCode}: ${res.body}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final diffs = (json['differences'] as List)
        .map<Difference>((d) => Difference.fromJson(d))
        .toList();
    return (
    json['full_proposal_text'] as String? ?? '',
    diffs,
    json['highlighted_proposal_pdf_url'] as String?
    );
  }
}
