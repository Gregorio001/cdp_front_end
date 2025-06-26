import 'dart:io';
import 'dart:typed_data';
import 'package:cdp_contract_comparison/models/analysis_models.dart';
import 'package:cdp_contract_comparison/providers/analysis_provider.dart';
import 'package:cdp_contract_comparison/screens/analysis_result_display.dart';
import 'package:cdp_contract_comparison/theme/app_theme.dart';
import 'package:cdp_contract_comparison/widget/chat_panel.dart';
import 'package:cdp_contract_comparison/widget/file_upload_card.dart';
import 'package:cdp_contract_comparison/widget/stat_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  File? _selectedFile;
  Uint8List? _webFileData;
  String? _fileName;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
      withData: kIsWeb,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final picked = result.files.single;
    setState(() {
      if (kIsWeb) {
        _webFileData = picked.bytes;
        _selectedFile = null;
      } else {
        _selectedFile = File(picked.path!);
        _webFileData = null;
      }
      _fileName = picked.name;
      Provider.of<AnalysisProvider>(context, listen: false).clearAnalysis();
    });
  }

  void _startAnalysis() {
    final provider = Provider.of<AnalysisProvider>(context, listen: false);
    const standardId = 'standard_v1'; // Esempio ID Contratto Standard

    if (kIsWeb) {
      if (_webFileData == null || _fileName == null) {
        _showErrorSnackBar('Per favore, seleziona un documento.');
        return;
      }
      provider.performAnalysisFromBytes(
        fileBytes: _webFileData!,
        filename: _fileName!,
        standardId: standardId,
      );
    } else {
      if (_selectedFile == null) {
        _showErrorSnackBar('Per favore, seleziona un documento.');
        return;
      }
      provider.performAnalysisFromFile(
        file: _selectedFile!,
        standardId: standardId,
      );
    }
  }

  void _clearAll() {
    setState(() {
      _selectedFile = null;
      _webFileData = null;
      _fileName = null;
    });
    Provider.of<AnalysisProvider>(context, listen: false).clearAnalysis();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: _buildMainContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildFileUploadSection(),
          const SizedBox(height: 32),
          _buildStatsGrid(),
          const SizedBox(height: 32),
          _buildAnalysisSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.description, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NextGen Finance Validator', style: Theme.of(context).textTheme.headlineMedium),
                Text(
                  "Cassa Depositi e Prestiti - Analisi Contratti",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
        TextButton.icon(
          onPressed: _clearAll,
          icon: const Icon(Icons.refresh),
          label: const Text("Nuova Analisi"),
          style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondaryColor),
        )
      ],
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: FileUploadCard(
                title: 'Contratto Standard',
                description: 'Il documento di riferimento',
                icon: Icons.gavel,
                iconColor: AppTheme.greenColor,
                iconBackgroundColor: AppTheme.greenLightColor,
                fileName: 'standard_v1.pdf', // Esempio statico
                onTap: () {}, // Nessuna azione
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: FileUploadCard(
                title: 'Contratto da Analizzare',
                description: 'Carica il documento da validare',
                icon: Icons.upload_file,
                iconColor: AppTheme.blueColor,
                iconBackgroundColor: AppTheme.blueLightColor,
                fileName: _fileName,
                onTap: _pickFile,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.analytics_outlined),
          label: const Text('Avvia Analisi'),
          onPressed: (_fileName != null && !context.watch<AnalysisProvider>().isLoading) ? _startAnalysis : null,
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 50),
              backgroundColor: AppTheme.blueColor
          ),
        )
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Consumer<AnalysisProvider>(
      builder: (context, provider, child) {
        final results = provider.analysisResult;

        // Calcolo delle statistiche dinamiche
        final int modifiedClauses = results?.where((c) => c.status == ClauseStatus.modified).length ?? 0;
        final int newClauses = results?.where((c) => c.status == ClauseStatus.brandnew).length ?? 0;
        final int deletedClauses = results?.where((c) => c.status == ClauseStatus.deleted).length ?? 0;
        final int historicalPrecedents = results?.expand((c) => c.historicalPrecedents).length ?? 0;

        return GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          children: [
            StatCard(
              icon: Icons.edit_note,
              iconColor: AppTheme.yellowColor,
              iconBgColor: AppTheme.yellowLightColor,
              value: modifiedClauses.toString(),
              title: 'Clausole Modificate',
              description: 'Variazioni dallo standard',
            ),
            StatCard(
              icon: Icons.add_box_outlined,
              iconColor: AppTheme.blueColor,
              iconBgColor: AppTheme.blueLightColor,
              value: newClauses.toString(),
              title: 'Clausole Nuove',
              description: 'Aggiunte nel documento',
            ),
            StatCard(
              icon: Icons.indeterminate_check_box_outlined,
              iconColor: AppTheme.redColor,
              iconBgColor: AppTheme.redLightColor,
              value: deletedClauses.toString(),
              title: 'Clausole Rimosse',
              description: 'Omesse dallo standard',
            ),
            StatCard(
              icon: Icons.history,
              iconColor: AppTheme.primaryColor,
              iconBgColor: AppTheme.primaryLightColor,
              value: historicalPrecedents.toString(),
              title: 'Precedenti Trovati',
              description: 'Casi storici rilevanti',
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalysisSection() {
    return Consumer<AnalysisProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Analisi in corso...'),
              ],
            ),
          );
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Text(
              'Errore: ${provider.errorMessage}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          );
        }

        if (provider.analysisResult != null) {
          return Column(
            children: [
              AnalysisResultDisplay(result: provider.analysisResult!),
              const SizedBox(height: 32),
              const ChatPanel(),
            ],
          );
        }

        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Text('Seleziona un documento e avvia l’analisi per visualizzare i risultati.'),
          ),
        );
      },
    );
  }
}
