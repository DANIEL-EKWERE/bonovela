import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/chat_models.dart';

class OnlineServiceController extends GetxController {
  final inputController = TextEditingController();
  final scrollController = ScrollController();

  final topics = Faq.byTopic.keys.toList();
  final RxString topic = Faq.byTopic.keys.first.obs;
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool botTyping = false.obs;

  static const _greeting =
      'Hi, please tap one of the common questions below for self-help. If you still need help, type your '
      'question and we\'ll reply within 72 hours. Thanks for your understanding.';

  @override
  void onInit() {
    super.onInit();
    _reset();
  }

  @override
  void onClose() {
    inputController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _reset() => messages.assignAll([ChatMessage(_greeting, fromUser: false, time: DateTime.now())]);

  List<Faq> get faqs => Faq.byTopic[topic.value]!;

  void ask(Faq faq) => _exchange(faq.question, faq.answer);

  void send() {
    final text = inputController.text.trim();
    if (text.isEmpty) return;
    inputController.clear();
    _exchange(
      text,
      'Thanks! Your message has been received. A member of our team will reply here within 72 hours.',
    );
  }

  Future<void> _exchange(String question, String answer) async {
    messages.add(ChatMessage(question, fromUser: true, time: DateTime.now()));
    _scrollDown();
    botTyping.value = true;
    await Future.delayed(const Duration(milliseconds: 900));
    botTyping.value = false;
    messages.add(ChatMessage(answer, fromUser: false, time: DateTime.now()));
    _scrollDown();
  }

  void _scrollDown() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });

  void clearHistory() => _reset();
}
