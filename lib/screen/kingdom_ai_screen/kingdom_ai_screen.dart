import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KingdomAIScreen extends StatefulWidget {
  const KingdomAIScreen({super.key});
  @override
  State<KingdomAIScreen> createState() => _KingdomAIScreenState();
}

class _KingdomAIScreenState extends State<KingdomAIScreen> {
  final _ctrl = TextEditingController();
  final RxList<Map<String, String>> _messages = <Map<String, String>>[].obs;
  final RxBool _loading = false.obs;
  int _selectedTool = 0;

  final List<Map<String, String>> tools = [
    {'icon': '✍️', 'label': 'Caption\nWriter'},
    {'icon': '🎬', 'label': 'Script\nGenerator'},
    {'icon': '📖', 'label': 'Bible Study\nAI'},
    {'icon': '💼', 'label': 'Business\nPlan'},
    {'icon': '🙏', 'label': 'Prayer\nBuilder'},
    {'icon': '📣', 'label': 'Content\nCalendar'},
    {'icon': '💰', 'label': 'Wealth\nCoach'},
    {'icon': '🎙️', 'label': 'Podcast\nOutline'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
          child: Column(children: [
        _buildHeader(),
        _buildToolGrid(),
        Expanded(child: _buildChat(context)),
        _buildInput(),
      ])),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          const Color(0xFF7B2FF7).withValues(alpha: 0.2),
          Colors.transparent
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      child: Row(children: [
        Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                    colors: [Color(0xFF7B2FF7), Color(0xFF00C6FF)]),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF7B2FF7).withValues(alpha: 0.5),
                      blurRadius: 16)
                ]),
            child: const Center(
                child: Text('AI',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)))),
        const SizedBox(width: 12),
        const Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('KingdomShift AI',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text(
              'Powered by faith. Built to help you create, inspire and multiply.',
              style: TextStyle(color: Colors.white54, fontSize: 12)),
        ])),
        IconButton(
            icon: const Icon(Icons.history, color: Colors.white70),
            onPressed: () {}),
      ]),
    );
  }

  Widget _buildToolGrid() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tools.length,
        itemBuilder: (_, i) {
          final sel = _selectedTool == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedTool = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFF7B2FF7) : const Color(0xFF12121E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: sel ? const Color(0xFF7B2FF7) : Colors.white12),
                boxShadow: sel
                    ? [
                        BoxShadow(
                            color:
                                const Color(0xFF7B2FF7).withValues(alpha: 0.4),
                            blurRadius: 12)
                      ]
                    : [],
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(tools[i]['icon']!,
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 4),
                    Text(tools[i]['label']!,
                        style: TextStyle(
                            color: sel ? Colors.white : Colors.white54,
                            fontSize: 10),
                        textAlign: TextAlign.center),
                  ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChat(BuildContext context) {
    return Obx(() => _messages.isEmpty
        ? Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('👑', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text('Ask KingdomAI anything',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'Captions, scripts, Bible study, business plans and more',
                style: TextStyle(color: Colors.white54, fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _promptChip('Write me a caption for my new video'),
              _promptChip('Create a 30-day content calendar'),
              _promptChip('Give me a Bible study on Proverbs 31'),
              _promptChip('Help me write a business plan'),
            ]),
          ]))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (_, i) {
              final m = _messages[i];
              final isUser = m['role'] == 'user';
              return Align(
                alignment:
                    isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(
                            colors: [Color(0xFF7B2FF7), Color(0xFF9B4BFF)])
                        : null,
                    color: isUser ? null : const Color(0xFF12121E),
                    borderRadius: BorderRadius.circular(16),
                    border: isUser ? null : Border.all(color: Colors.white12),
                  ),
                  child: Text(m['content']!,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 14)),
                ),
              );
            },
          ));
  }

  Widget _promptChip(String text) {
    return GestureDetector(
      onTap: () {
        _ctrl.text = text;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF12121E),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: const Color(0xFF7B2FF7).withValues(alpha: 0.4)),
        ),
        child: Text(text,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
          color: const Color(0xFF0A0A0F),
          border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.08)))),
      child: Row(children: [
        Expanded(
            child: Container(
          decoration: BoxDecoration(
              color: const Color(0xFF12121E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white12)),
          child: TextField(
            controller: _ctrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Ask KingdomAI...',
              hintStyle: TextStyle(color: Colors.white38),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onSubmitted: (_) => _sendMessage(),
          ),
        )),
        const SizedBox(width: 8),
        Obx(() => GestureDetector(
              onTap: _loading.value ? null : _sendMessage,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF7B2FF7), Color(0xFF00C6FF)]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF7B2FF7).withValues(alpha: 0.4),
                        blurRadius: 12)
                  ],
                ),
                child: _loading.value
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
              ),
            )),
      ]),
    );
  }

  void _sendMessage() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    _messages.add({'role': 'user', 'content': text});
    _loading.value = true;
    Future.delayed(const Duration(seconds: 1), () {
      _messages.add({
        'role': 'ai',
        'content':
            'Kingdom response coming soon! The anointing on your life is greater than any algorithm. Keep building, keep creating, keep shifting!'
      });
      _loading.value = false;
    });
  }
}
