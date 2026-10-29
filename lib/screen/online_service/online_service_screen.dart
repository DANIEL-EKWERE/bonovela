import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import 'controller/online_service_controller.dart';
import 'models/chat_models.dart';

class OnlineServiceScreen extends GetView<OnlineServiceController> {
  const OnlineServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.plum,
          foregroundColor: Colors.white,
          centerTitle: false,
          leading: IconButton(
            onPressed: () => _confirmLeave(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          title: const Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white,
                child: Icon(Icons.support_agent_rounded, size: 18, color: AppColors.plum),
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text('Online Service',
                    overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
          actions: [
            IconButton(onPressed: () => _showMenu(context), icon: const Icon(Icons.more_horiz_rounded)),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Obx(() => ListView(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.all(12),
                    children: [
                      for (final (i, m) in controller.messages.indexed) ...[
                        _Bubble(message: m),
                        // The FAQ card sits right under the greeting.
                        if (i == 0) _FaqCard(),
                      ],
                      if (controller.botTyping.value)
                        const _Bubble(message: ChatMessage('…', fromUser: false, time: null)),
                    ],
                  )),
            ),
            _InputBar(),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Clear chat history', textAlign: TextAlign.center, style: TextStyle(color: AppColors.error)),
              onTap: () {
                Get.back();
                controller.clearHistory();
              },
            ),
            const Divider(),
            ListTile(title: const Text('Cancel', textAlign: TextAlign.center), onTap: Get.back),
          ],
        ),
      ),
    );
  }

  void _confirmLeave(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        content: const Text('Do you want to end the session?', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearHistory();
              Get.back();
              Get.back();
            },
            child: const Text('Close session', style: TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: const Text('Leave temporarily', style: TextStyle(color: AppColors.plum)),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;

  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final user = message.fromUser;
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: user ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(user ? 14 : 4),
            bottomRight: Radius.circular(user ? 4 : 14),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: user ? Colors.white : AppColors.textPrimary, fontSize: 14, height: 1.45),
        ),
      ),
    );
  }
}

class _FaqCard extends GetView<OnlineServiceController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    for (final t in controller.topics)
                      GestureDetector(
                        onTap: () => controller.topic.value = t,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: controller.topic.value == t ? AppColors.primary : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            t,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: controller.topic.value == t ? FontWeight.w600 : FontWeight.w400,
                              color: controller.topic.value == t ? AppColors.textPrimary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              for (final f in controller.faqs)
                ListTile(
                  dense: true,
                  title: Text(f.question, style: const TextStyle(fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                  onTap: () => controller.ask(f),
                ),
            ],
          )),
    );
  }
}

class _InputBar extends GetView<OnlineServiceController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.inputController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => controller.send(),
                  decoration: const InputDecoration(hintText: 'Please describe your question…', isDense: true),
                ),
              ),
              IconButton(
                onPressed: controller.send,
                icon: const Icon(Icons.send_rounded, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
