import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_indicator.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;

  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    // Add welcome message
    _addMessage('assistant',
        'Hello! I\'m your AI Maternal Health Assistant. I\'m here to help you with questions about medications, pregnancy health, symptoms, and general maternal wellness. How can I assist you today?');
  }

  void _initSpeech() async {
    _speechEnabled = await _speech.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _speech.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addMessage(String role, String content) {
    setState(() {
      _messages.add({'role': role, 'content': content});
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppConstants.animationNormal,
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final userMessage = _messageController.text.trim();
    if (userMessage.isEmpty) return;

    _addMessage('user', userMessage);
    _messageController.clear();
    _stopListening();
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.together.xyz/v1/chat/completions'),
        headers: {
          'Authorization':
              'Bearer tgp_v1_onFMvvKE406HiInIX9ZxmQtZB-xk1uTumlxUHlFUxJc',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "meta-llama/Llama-3.3-70B-Instruct-Turbo",
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a professional AI Maternal Health Assistant for pregnant women and new mothers. Always provide accurate, helpful, and empathetic responses about pregnancy, medications, symptoms, nutrition, and maternal health. Always prioritize safety and recommend consulting healthcare professionals for serious concerns. Be concise but informative. Use bullet points when listing information. If a question is outside your scope, politely redirect to appropriate medical professionals."
            },
            ..._messages
                .map((m) => {'role': m['role'], 'content': m['content']}),
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['choices'][0]['message']['content'];
        _addMessage('assistant', message);
      } else {
        _addMessage('assistant',
            'I apologize, but I\'m experiencing some technical difficulties. Please try again in a moment. For urgent health concerns, please contact your healthcare provider immediately.');
      }
    } catch (e) {
      _addMessage('assistant',
          'I\'m having trouble connecting right now. Please try again later. If you have urgent health questions, please consult with your healthcare provider.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startListening() async {
    if (!_speechEnabled) return;

    setState(() {
      _isListening = true;
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _messageController.text = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: "en_US",
    );
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.aiAssistant.withOpacity(0.05),
              AppColors.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            // Enhanced Header
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 15,
                left: 20,
                right: 20,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.aiAssistant,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.aiAssistant.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          FontAwesomeIcons.robot,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AI Health Assistant',
                              style: TextStyle(
                                fontSize: AppConstants.fontTitle,
                                fontWeight: FontWeight.bold,
                                color: AppColors.aiAssistant,
                              ),
                            ),
                            Text(
                              'Your maternal health companion',
                              style: TextStyle(
                                fontSize: AppConstants.fontM,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () {
                          _showInfoDialog();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Welcome Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.aiAssistant.withOpacity(0.1),
                          AppColors.primary.withOpacity(0.1)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.aiAssistant.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.aiAssistant.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.heartPulse,
                          color: AppColors.aiAssistant,
                          size: 40,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ask about medications, pregnancy symptoms, nutrition, and maternal health!',
                            style: TextStyle(
                              fontSize: AppConstants.fontM,
                              color: AppColors.aiAssistant,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Quick Actions
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingM,
                vertical: AppConstants.paddingS,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildQuickActionChip(
                        'Medication Safety', Icons.medication),
                    _buildQuickActionChip(
                        'Pregnancy Symptoms', Icons.pregnant_woman),
                    _buildQuickActionChip('Nutrition Tips', Icons.restaurant),
                    _buildQuickActionChip('Exercise', Icons.fitness_center),
                  ],
                ),
              ),
            ),

            // Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppConstants.paddingM),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message['role'] == 'user';
                  return _buildMessageBubble(message['content']!, isUser);
                },
              ),
            ),

            // Loading Indicator
            if (_isLoading)
              Container(
                margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
                child: const LoadingIndicator(),
              ),

            // Enhanced Input Area
            Container(
              margin: const EdgeInsets.all(AppConstants.paddingM),
              padding: const EdgeInsets.all(AppConstants.paddingM),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.aiAssistant.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: AppColors.aiAssistant.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Microphone button
                  if (_speechEnabled)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isListening
                              ? [
                                  AppColors.error,
                                  AppColors.error.withOpacity(0.8)
                                ]
                              : [
                                  AppColors.warning,
                                  AppColors.warning.withOpacity(0.8)
                                ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening
                                    ? AppColors.error
                                    : AppColors.warning)
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _isLoading
                              ? null
                              : () {
                                  if (_isListening) {
                                    _stopListening();
                                  } else {
                                    _startListening();
                                  }
                                },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              _isListening
                                  ? FontAwesomeIcons.stop
                                  : FontAwesomeIcons.microphone,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_speechEnabled) const SizedBox(width: 12),
                  // Text input field
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onSubmitted: (_) => _sendMessage(),
                      style: const TextStyle(
                        fontSize: AppConstants.fontM,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: _isListening
                            ? 'Listening...'
                            : 'Ask about your health...',
                        hintStyle: TextStyle(
                          color: AppColors.aiAssistant.withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceLight,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: AppConstants.paddingM,
                          horizontal: AppConstants.paddingM,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.aiAssistant.withOpacity(0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.aiAssistant,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Send button
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.aiAssistant,
                          AppColors.aiAssistant.withOpacity(0.8)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.aiAssistant.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _isLoading ? null : _sendMessage,
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            FontAwesomeIcons.paperPlane,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: AppConstants.paddingS),
      child: ActionChip(
        avatar:
            Icon(icon, size: AppConstants.iconS, color: AppColors.aiAssistant),
        label: Text(
          label,
          style: const TextStyle(color: AppColors.aiAssistant),
        ),
        backgroundColor: AppColors.aiAssistant.withOpacity(0.1),
        onPressed: () {
          _messageController.text = 'Tell me about $label';
          _sendMessage();
        },
      ),
    );
  }

  Widget _buildMessageBubble(String message, bool isUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.aiAssistant,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.aiAssistant.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  FontAwesomeIcons.robot,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.paddingM,
                  horizontal: AppConstants.paddingM,
                ),
                decoration: BoxDecoration(
                  color: isUser
                      ? AppColors.aiAssistant.withOpacity(0.15)
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isUser
                              ? AppColors.aiAssistant
                              : AppColors.shadowLight)
                          .withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color:
                        (isUser ? AppColors.aiAssistant : AppColors.shadowLight)
                            .withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: AppConstants.fontM,
                    color:
                        isUser ? AppColors.aiAssistant : AppColors.textPrimary,
                    fontWeight: isUser ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
            if (isUser) ...[
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.aiAssistant.withOpacity(0.3),
                    width: 1,
                  ),
                  color: AppColors.aiAssistant.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.aiAssistant,
                  size: 18,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Health Assistant'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'I am your AI Maternal Health Assistant, designed to provide information about:',
              style: TextStyle(fontSize: AppConstants.fontM),
            ),
            SizedBox(height: AppConstants.paddingM),
            Text('• Medication safety during pregnancy'),
            Text('• Common pregnancy symptoms'),
            Text('• Nutrition and exercise tips'),
            Text('• General maternal health guidance'),
            SizedBox(height: AppConstants.paddingM),
            Text(
              'Note: I am not a substitute for professional medical advice. Always consult with your healthcare provider for medical concerns.',
              style: TextStyle(
                fontSize: AppConstants.fontS,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
