import 'package:cdp_contract_comparison/models/analysis_models.dart';
import 'package:cdp_contract_comparison/providers/analysis_provider.dart';
import 'package:cdp_contract_comparison/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class ChatPanel extends StatefulWidget {
  const ChatPanel({super.key});

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final _chatController = TextEditingController();
  final _scrollController = ScrollController();

  void _sendMessage() {
    final provider = Provider.of<AnalysisProvider>(context, listen: false);
    if (_chatController.text.trim().isNotEmpty) {
      provider.sendChatMessage(_chatController.text.trim());
      _chatController.clear();
    }
  }

  void _scrollToBottom() {
    // Aggiungi un piccolo ritardo per permettere alla UI di costruire il nuovo messaggio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.backgroundColor,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Chat con l'Esperto AI",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              "Poni domande specifiche sulle clausole analizzate.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            // Area della cronologia chat
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Consumer<AnalysisProvider>(
                builder: (context, provider, child) {
                  // Ogni volta che la history cambia, scrolla in fondo
                  _scrollToBottom();
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: provider.chatHistory.length,
                    itemBuilder: (context, index) {
                      final message = provider.chatHistory[index];
                      return _buildMessageBubble(message);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Area di input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'Scrivi qui la tua domanda...',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Mostra un caricamento o il bottone di invio
                Consumer<AnalysisProvider>(
                  builder: (context, provider, child) {
                    return provider.isChatLoading
                        ? const CircularProgressIndicator()
                        : IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Text(
                message.text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isUser ? Colors.white : AppTheme.textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
