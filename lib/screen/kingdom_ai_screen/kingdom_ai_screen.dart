import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

const _edgeFunctionUrl = 'https://cotcogrkmtgibbpwhxrg.supabase.co/functions/v1/dynamic-endpoint';
const _supabasePublishableKey = 'sb_publishable_FxXXeD03pQNBCb7fl5OGkQ_JUmKRsJ9';

class KingdomAIScreen extends StatefulWidget {
  const KingdomAIScreen({super.key});
  @override
  State<KingdomAIScreen> createState() => _KingdomAIScreenState();
}

class _KingdomAIScreenState extends State<KingdomAIScreen> {
  final _ctrl = TextEditingController();
  final RxList<Map<String, String>> _messages = <Map<String, String>>[].obs;
  final RxBool _loading = false.obs;
  final RxInt _remainingToday = 5.obs;
  int _selectedTool = 0;

  final List<Map<String, String>> tools = [
    {
      'icon': '✍️',
      'label': 'Caption\nWriter',
      'systemPrompt':
          'You are a social media caption writer for KingdomShift, a faith-based creator platform. Write short, engaging, faith-inspired captions with relevant hashtags. Keep responses concise and ready to copy-paste.',
      'starterPrompt': 'Write me a caption for a video about staying faithful during hard times',
    },
    {
      'icon': '🎬',
      'label': 'Script\nGenerator',
      'systemPrompt':
          'You are a video script writer for faith-based content creators. Write clear, engaging short-form video scripts with a hook, body, and call to action. Keep it practical and ready to film.',
      'starterPrompt': 'Write a 60-second video script about walking in your purpose',
    },
    {
      'icon': '🧠',
      'label': 'Mindset\nCoach',
      'systemPrompt':
          'You are a mindset and personal growth coach. Give practical, encouraging guidance on discipline, motivation, overcoming setbacks, and building healthy habits. Keep advice grounded and actionable.',
      'starterPrompt': 'Help me build a morning routine that sets up my whole day',
    },
    {
      'icon': '💼',
      'label': 'Business\nPlan',
      'systemPrompt':
          'You are a business strategist helping faith-driven entrepreneurs build their ventures. Give practical, actionable business advice grounded in Kingdom principles of stewardship and excellence.',
      'starterPrompt': 'Help me outline a business plan for my faith-based brand',
    },
    {
      'icon': '🙏',
      'label': 'Prayer\nBuilder',
      'systemPrompt':
          'You are a prayer writing assistant. Write heartfelt, scripture-grounded prayers tailored to what the user is going through. Keep the tone warm, personal, and reverent.',
      'starterPrompt': 'Write a prayer for strength and clarity this week',
    },
    {
      'icon': '📣',
      'label': 'Content\nCalendar',
      'systemPrompt':
          'You are a content strategist for faith-based creators. Help plan content calendars, post ideas, and posting schedules that build audience and stay consistent with Kingdom values.',
      'starterPrompt': 'Create a 7-day content calendar for my platform',
    },
    {
      'icon': '💰',
      'label': 'Wealth\nCoach',
      'systemPrompt':
          'You are a faith-based financial and wealth-building coach. Give practical guidance on budgeting, saving, investing, and building generational wealth, grounded in biblical stewardship principles.',
      'starterPrompt': 'Give me 3 practical steps to start building generational wealth',
    },
    {
      'icon': '🎙️',
      'label': 'Podcast\nOutline',
      'systemPrompt':
          'You are a podcast outline writer. Help create structured podcast episode outlines with intro, segments, talking points, and closing, tailored to faith-based and personal development content.',
      'starterPrompt': 'Outline a podcast episode about overcoming discouragement',
    },
  ];

  final Map<int, List<String>> toolSuggestions = {
    0: [
      'Write me a caption for my new video',
      'Give me 3 caption styles for a testimony post',
      'Write a caption that gets more comments',
    ],
    1: [
      'Write a 60-second video script about walking in your purpose',
      'Script a video introducing myself to new followers',
      'Write a script for a product/service promo',
    ],
    2: [
      'Help me build a morning routine that sets up my whole day',
      'Give me 3 ways to stay consistent when I feel unmotivated',
      'Help me reframe a setback into a lesson',
    ],
    3: [
      'Help me outline a business plan for my faith-based brand',
      'What should I prioritize in my first 90 days?',
      'Help me price my product or service',
    ],
    4: [
      'Write a prayer for strength and clarity this week',
      'Write a prayer for someone going through a hard season',
      'Write a prayer of gratitude to open my day',
    ],
    5: [
      'Create a 7-day content calendar for my platform',
      'Give me 10 post ideas for this month',
      'Help me plan a launch week of content',
    ],
    6: [
      'Give me 3 practical steps to start building generational wealth',
      'Help me create a simple monthly budget',
      'Explain how to start investing with a small amount',
    ],
    7: [
      'Outline a podcast episode about overcoming discouragement',
      'Help me structure my first podcast episode',
      'Give me 5 podcast episode ideas',
    ],
  };

  Future<void> _sendMessage() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    if (_loading.value) return;

    final userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _messages.add({'role': 'ai', 'content': 'Please sign in to use KingdomAI.'});
      return;
    }

    _ctrl.clear();
    _messages.add({'role': 'user', 'content': text});
    _loading.value = true;

    try {
      final response = await http.post(
        Uri.parse(_edgeFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_supabasePublishableKey',
          'apikey': _supabasePublishableKey,
        },
        body: jsonEncode({
          'userId': userId,
          'message': text,
          'systemPrompt': tools[_selectedTool]['systemPrompt'],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _messages.add({'role': 'ai', 'content': data['response'] ?? 'No response received.'});
        _remainingToday.value = data['remainingToday'] ?? 0;
      } else if (response.statusCode == 429) {
        final data = jsonDecode(response.body);
        _messages.add({
          'role': 'ai',
          'content': data['error'] ?? 'Daily limit reached. Try again tomorrow.'
        });
        _remainingToday.value = 0;
      } else {
        _messages.add({
          'role': 'ai',
          'content': 'Something went wrong. Please try again in a moment.'
        });
      }
    } catch (e) {
      _messages.add({
        'role': 'ai',
        'content': 'Connection error. Please check your internet and try again.'
      });
    } finally {
      _loading.value = false;
    }
  }

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
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('KingdomShift AI',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Obx(() => Text(
              '${_remainingToday.value} of 5 free messages left today',
              style: const TextStyle(color: Colors.white54, fontSize: 12))),
        ])),
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
            onTap: () {
              setState(() => _selectedTool = i);
              _ctrl.text = tools[i]['starterPrompt'] ?? '';
              _ctrl.selection = TextSelection.fromPosition(
                  TextPosition(offset: _ctrl.text.length));
            },
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (toolSuggestions[_selectedTool] ?? [])
                  .map((s) => _promptChip(s))
                  .toList(),
            ),
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
}
