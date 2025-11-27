import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:veridian/providers/localization_provider.dart';
import 'package:veridian/services/support_service.dart';
import 'package:veridian/theme.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isBotThinking = false;

  final Map<String, Map<String, String>> _faqDatabase = {
    'ru': {
      "Как изменить пароль?": "Перейдите в Профиль -> Настройки -> Безопасность -> Смена пароля.",
      "Где найти банкомат?": "На главной странице нажмите на кнопку 'Банк на карте' в разделе 'Полезное'.",
      "Как перевести деньги?": "Используйте вкладку 'Переводы' в нижнем меню или быструю кнопку на главной.",
      "Лимиты по картам": "Вы можете настроить лимиты в разделе 'Карты' -> Настройки карты.",
    },
    'kk': {
      "Құпия сөзді қалай өзгертуге болады?": "Профиль -> Баптаулар -> Қауіпсіздік -> Құпия сөзді өзгерту бөліміне өтіңіз.",
      "Банкоматты қайдан табуға болады?": "Басты беттегі 'Пайдалы' бөліміндегі 'Картадағы банк' түймесін басыңыз.",
      "Ақшаны қалай аударуға болады?": "Төменгі мәзірдегі 'Аударымдар' қойындысын немесе басты беттегі жылдам түймені пайдаланыңыз.",
      "Карта лимиттері": "Сіз лимиттерді 'Карталар' -> Карта баптаулары бөлімінде реттей аласыз.",
    },
    'en': {
      "How to change password?": "Go to Profile -> Settings -> Security -> Change Password.",
      "Where to find an ATM?": "Click on 'Bank on Map' in the 'Useful' section on the Home page.",
      "How to transfer money?": "Use the 'Transfer' tab in the bottom menu or the quick button on the home screen.",
      "Card limits": "You can adjust limits in the 'Cards' -> Card Settings section.",
    }
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addBotMessage(_getWelcomeMessage());
    });
  }

  String _getWelcomeMessage() {
    final lang = context.read<LocalizationProvider>().currentLanguage.name;
    switch (lang) {
      case 'kk':
        return "Сәлеметсіз бе! Мен Veridian виртуалды көмекшісімін. Сұрағыңызды қойыңыз.";
      case 'en':
        return "Hello! I am the Veridian virtual assistant. How can I help you?";
      default:
        return "Здравствуйте! Я виртуальный помощник Veridian. Чем могу помочь?";
    }
  }

  void _addMessage(String text, bool isUser) {
    if (!mounted) return;
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: isUser,
        time: DateTime.now(),
      ));
      if (!isUser) _isBotThinking = false;
    });
    _scrollToBottom();
  }

  void _addBotMessage(String text) => _addMessage(text, false);

  void _handleUserSubmit(String text) {
    if (text.trim().isEmpty) return;

    _addMessage(text, true);
    _textController.clear();

    setState(() => _isBotThinking = true);

    _processResponse(text);
  }

  Future<void> _processResponse(String userQuery) async {
    final lang = context.read<LocalizationProvider>().currentLanguage.name;
    final faq = _faqDatabase[lang] ?? _faqDatabase['ru']!;

    String? localAnswer;
    faq.forEach((question, answer) {
      if (userQuery.toLowerCase().contains(question.toLowerCase())) {
        localAnswer = answer;
      }
    });

    if (localAnswer != null) {
      await Future.delayed(const Duration(milliseconds: 600));
      _addBotMessage(localAnswer!);
    } else {
      final supportService = context.read<SupportService>();
      final reply = await supportService.sendMessage(userQuery, lang);

      if (reply != null) {
        _addBotMessage(reply);
      } else {
        _showErrorFallback(lang);
      }
    }
  }

  void _showErrorFallback(String lang) {
    String msg;
    if (lang == 'kk') {
      msg = "Кешіріңіз, сервермен байланыс жоқ. Кейінірек көріңіз.";
    } else if (lang == 'en') {
      msg = "Connection error. Please try again later.";
    } else {
      msg = "Ошибка соединения с сервером. Попробуйте позже.";
    }
    _addBotMessage(msg);
  }

  void _scrollToBottom() {
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
    final lang = context.watch<LocalizationProvider>().currentLanguage.name;
    final currentFaq = _faqDatabase[lang] ?? _faqDatabase['ru']!;
    final quickQuestions = currentFaq.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          lang == 'en' ? 'Support' : (lang == 'kk' ? 'Қолдау' : 'Поддержка'),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          if (_isBotThinking)
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).primaryColor)
                    ),
                    const SizedBox(width: 8),
                    Text(
                      lang == 'en' ? 'Typing...' : (lang == 'kk' ? 'Жазуда...' : 'Печатает...'),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          Container(
            height: 50,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: quickQuestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return ActionChip(
                  label: Text(quickQuestions[index]),
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  labelStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.2))
                  ),
                  onPressed: () => _handleUserSubmit(quickQuestions[index]),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: lang == 'en' ? 'Ask a question...' : (lang == 'kk' ? 'Сұрақ қойыңыз...' : 'Введите сообщение...'),
                        filled: true,
                        fillColor: const Color(0xFFF0F2F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onSubmitted: _handleUserSubmit,
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    onPressed: () => _handleUserSubmit(_textController.text),
                    mini: true,
                    elevation: 0,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    final timeString = DateFormat('HH:mm').format(message.time);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(0),
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(20),
          ),
          boxShadow: [
            if (!isUser)
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 16,
                  height: 1.4
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeString,
              style: TextStyle(
                color: isUser ? Colors.white.withOpacity(0.7) : Colors.grey[400],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});
}